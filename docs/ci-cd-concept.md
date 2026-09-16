# CI/CD Concept

Goal: verify every change to this repository automatically (does it still evaluate, build, and follow the formatting rules?) and turn `main` into a source of prebuilt artifacts, so that `make home` / `make darwin` mostly downloads instead of compiling.

Platform: GitHub Actions on `github.com/TheBromo/nixos-config`. The repository is public, so both `ubuntu-latest` (x86_64-linux) and `macos-15` (aarch64-darwin) runners are free.

## 1. Constraints discovered in this repository

These shape the design and are worth keeping in mind before changing anything.

| Constraint | Consequence for CI |
| --- | --- |
| `homeConfigurations` is not a standard flake output, but home-manager's `flakeModule` registers a check for it, so the installed Nix does report `homeConfigurations.<name> (build skipped)`. Relying on that alone is fragile, and it does not give the configurations a stable check name. | The configurations are additionally re-exported as `checks.<system>.home-<name>` (§2.1), which pins the names CI depends on. |
| Cross-system *evaluation* works. Evaluating `homeConfigurations.manuel` (x86_64-linux) on an aarch64-darwin machine succeeds and returns a `.drv` path. | One cheap Linux job can evaluate *both* hosts. A macOS runner is only needed for actually *building* the Darwin closure. |
| The closure of `manuel-darwin` is **8.6 GiB** (the Neovim module pulls in a large set of language servers, LLVM clang-tools, rust-analyzer, …). | A full closure build does not fit comfortably on a default hosted runner (~14 GiB free on macOS, ~21 GiB on Ubuntu after cleanup). Full builds need a disk-cleanup step and should not run on every push. |
| `modules/home-manager/TX-02/default.nix` uses `src = "${self}/secrets/TX-02.tar.xz"`. The content under `secrets/**` is git-crypt encrypted because its licence forbids publication and this repository is public. | CI never gets the key. The font is behind `custom.tx02.enable` (default `true`), and CI builds the `ci-<host>` variant with it set to `false`. Evaluation is unaffected — it never reads the file content — so the encrypted tree still evaluates fine. |
| Own derivations that upstream caches cannot provide: `packages.tree-sitter-cli` (Rust build with a custom `src`), the `TX-02` font, and the AppImage modules (`helium`, `t3code`, `headlamp`). | These are the parts that are actually *our* code and worth building on every PR — they are small compared to the full closure. |
| Only `tree-sitter-cli` is exposed as a flake package. The AppImage derivations are defined inside module `let` bindings, and no current host imports `helium`, `t3code`, `headlamp`, or `slack`. | To build them in CI, they must first be exposed as `perSystem.packages.*` (the module then consumes `self.packages.<system>.<name>`, exactly like `nvim-config` already does with `tree-sitter-cli`). Without that refactor, nothing verifies their hashes — and the unused AppImage modules are never built at all. `TX-02` stays out of CI on purpose, see the row above. |
| Inputs `neovim-nightly-overlay`, `ghostty`, and `herdr` build from source unless their upstream binary caches are configured. | Add the `nix-community` and `ghostty` substituters to the CI Nix config, otherwise a full build compiles Zig and Rust from scratch. |
| The repository is public and git-crypt protected. | A guard job verifies that everything under `secrets/**` is still encrypted in the commit. No workflow ever decrypts, and no workflow holds the key. |
| `makefile` still has `zhaw` and `hexagon` targets, but `modules/hosts/` only contains `manuel` and `manuel-darwin`. `CLAUDE.md` documents four hosts. | The host list must come from one place. Deriving the CI matrix from `nix eval .#homeConfigurations --apply builtins.attrNames` keeps CI correct automatically and makes the stale targets visible. |

## 2. Repository-side prerequisites (implemented)

CI calls into the flake instead of reimplementing checks in YAML. Three additions make that possible; all of them are in place.

### 2.1 Re-export the home configurations as flake checks

`modules/checks/default.nix` maps every `homeConfigurations.<name>` whose target system matches the evaluated system to `checks.<system>.home-<name>`.

Effects:

- `nix flake check --no-build --all-systems` evaluates every host configuration, including the Darwin one from a Linux runner.
- `nix flake check` on a matching machine builds them.
- The check names (`home-manuel`, `home-manuel-darwin`) are derived, so a new host is covered without touching CI.

### 2.2 Formatting via `treefmt-nix`

New input `treefmt-nix` plus `modules/formatter/default.nix`, with `nixfmt` (the style the repository already uses) and `yamlfmt` (for the workflow files). `secrets/**`, `secret-key`, lock files and binaries are excluded, so nothing encrypted is ever rewritten.

Gives `nix fmt` locally and `checks.<system>.treefmt` for CI.

### 2.3 Static analysis via `modules/lint`

`checks.<system>.lint` is a `runCommand` over a `fileset` of all `.nix` files, `statix.toml` and `.github/workflows`, running:

- `statix check` — Nix anti-patterns,
- `deadnix --fail` — unused bindings and lambda arguments,
- `actionlint` (with `shellcheck`) — the workflow files and their `run:` blocks.

These are deliberately *not* treefmt formatters: `statix fix` would rewrite code, and a check should only report.

`statix.toml` disables two lints:

- `empty_pattern` (38 findings) — `{ ... }:` is the idiomatic module signature here; rewriting all of them to `_:` would hide that a file is a module.
- `repeated_keys` (21 findings) — separate `programs.a` / `programs.b` assignments keep related options together, and the module system merges them anyway.

Nothing else fires, so the gate is green without repository-wide churn.

**Lint debt that was fixed to get there** (was measured on `4a29870`):

- `nixfmt`: `modules/home-manager/info/default.nix` reformatted.
- `deadnix`: `headlamp` unused `pkgs`, `t3code` unused `lib` and `pkgs` — the `extraPkgs` arguments became `_`.

## 3. Pipeline layers

Four workflows, ordered from cheapest to most expensive.

### Layer 0 — local (no CI)

- `nix fmt` before committing.
- Optional: a git `pre-commit` hook (or `git-hooks.nix`) running `nix fmt` on staged `.nix` files, so CI rarely fails on formatting.

### Layer 1 — `ci.yml` (implemented), triggered on pull requests, pushes to `main`, and `workflow_dispatch`

Fast feedback, no secrets, four parallel jobs on `ubuntu-latest`. `permissions: contents: read` only, and `concurrency` cancels superseded runs.

1. **`secrets-guard`** — asserts that every tracked path under `secrets/` starts with the magic bytes `\0GITCRYPT`, and that `secret-key` (the git-crypt key itself) is not tracked at all. Runs without any secret and needs no Nix. Verified both ways against a keyless clone: 56 encrypted files pass, a planted plaintext file fails.
2. **`checks`** — `nix flake check --no-build --all-systems --show-trace`, then `nix build` of `checks.x86_64-linux.treefmt` and `checks.x86_64-linux.lint`. The evaluation covers both hosts, including the Darwin one, thanks to cross-system evaluation. `--no-build` is deliberate: building the host closures would mean 8.6 GiB per host and belongs in Layer 2.
3. **`lock`** — `DeterminateSystems/flake-checker-action` with `fail-mode: false`, warning when `flake.lock` drifts too far behind or points at an unsupported branch.
4. **`build-own`** — `nix build .#packages.x86_64-linux.<name>` for every derivation that upstream caches cannot supply. Today that is only `tree-sitter-cli`; after the refactor described in §1 it also covers the AppImage packages, but never `TX-02`. Small, fast, and it catches the failure mode this repository actually hits: a stale AppImage or `fetchCargoVendor` hash after a version bump. It reads from the `thebromo` cache but does not push, so it needs no secret and works on fork pull requests too.

All actions are pinned to commit SHAs with the tag in a trailing comment.

### Layer 2 — `build.yml` (implemented), triggered on pushes to `main`, a nightly schedule (03:00 UTC), and `workflow_dispatch`

Full closure realization plus cache population. This is the "CD" part: after it finishes, a local `make home` or `make darwin` is a download instead of a build.

A `discover` job derives the matrix from the flake, so a new host needs no workflow change:

```bash
nix eval --json .#homeConfigurations --apply \
  'cfgs: builtins.mapAttrs (_: c: c.pkgs.stdenv.hostPlatform.system) cfgs'
```

`jq` then maps each target system to a runner (`x86_64-linux` → `ubuntu-latest`, `aarch64-linux` → `ubuntu-24.04-arm`, `aarch64-darwin` → `macos-15`) and fails loudly on an unmapped system. Today that yields:

| Host | System | Runner |
| --- | --- | --- |
| `manuel` | `x86_64-linux` | `ubuntu-latest` |
| `manuel-darwin` | `aarch64-darwin` | `macos-15` |

Steps per matrix entry, `fail-fast: false` so one broken host does not hide the other:

1. Free disk space — `jlumbroso/free-disk-space` on Linux, pruning the Android SDK, extra Xcode versions and simulator caches on macOS. Required because of the 8.6 GiB closure.
2. Install Nix with the extra substituters `thebromo`, `nix-community` and `ghostty`, so Neovim nightly, Ghostty and herdr are downloaded instead of compiled.
3. `cachix/cachix-action` with cache `thebromo` and `CACHIX_AUTH_TOKEN`; its post step pushes everything the job built.
4. `nix build .#packages.<system>.ci-<host> --no-link --print-out-paths --print-build-logs`.

### The `ci-<host>` variant

`modules/ci/default.nix` derives one package per host from the host's own configuration:

```nix
(homeConfiguration.extendModules {
  modules = [ { custom.nonRedistributable.enable = false; } ];
}).activationPackage
```

So CI builds the identical closure minus everything whose licence forbids republication. Three things hang off that one flag today: the git-crypt encrypted `TX-02` font, the `claude-code` binary from the `llm-agents.nix` input, and `1password-cli`.

Two reasons, and the second one is the important one:

- CI has no git-crypt key, so a `TX-02` build would fail.
- The closure is pushed to a *public* Cachix cache. Pushing any of the three would republish content whose licence forbids exactly that.

`modules/home-manager/non-redistributable` also asserts that, whenever the flag is `false`, no `home.packages` entry has a `meta.license` with `redistributable = false`. That assertion is not decoration: it caught `1password-cli` on its first evaluation, which had already been pushed to the public cache by the first `build.yml` run.

The mechanism has to be "never enters the store", not "not in the final closure": cachix pushes every path the job produced, substituted ones included. Measured on run 35069655787 — 363 paths pushed, 34 of them from upstream substituters. Hence `build.yml` also deliberately omits the `cache.numtide.com` substituter, and a post-build step greps the closure for the restricted names.

Verified locally: the `ci-manuel-darwin` closure has 0 references to `TX-02`, the full `home-manuel-darwin` closure has 1; both are 8.6 GiB, so nothing else changes. No workflow decrypts anything, and the `GIT_CRYPT_KEY` secret has been deleted from the repository again.

The consuming side is `modules/home-manager/nix-settings`, imported by both hosts: it writes the three substituters and their public keys to `~/.config/nix/nix.conf`. A daemon install only honours a user-level substituter when the user is in `trusted-users`; otherwise Nix ignores it with a warning and the switch simply builds locally as before.

Optional extra step: `home-manager build --flake .#<host>` inside a container to smoke-test the *activation script* itself. It has limited value here because `nvim-config`'s activation hook clones a Git repository and writes to `$HOME`; treat this as a later addition, not part of the initial concept.

### Layer 3 — `update.yml` (implemented), Mondays 04:00 UTC plus `workflow_dispatch`

Dependency maintenance, replacing the manual `make up`.

1. `nix flake update`, with the output kept in `$RUNNER_TEMP/update.log`. If `flake.lock` is unchanged, the job stops here and opens nothing.
2. `nix flake check --no-build --all-systems` plus builds of the `treefmt` and `lint` checks — the same gates as Layer 1, run *in this job*. This is not redundant: a pull request opened with `GITHUB_TOKEN` does not trigger `ci.yml`, so without it the update PR would carry no checks at all.
3. The PR body is assembled from the `•  Updated input …` block of the log, which contains the old and the new revision per input (verified against a real `nix flake update`: 8 inputs, 3 lines each).
4. `peter-evans/create-pull-request` opens `chore/update-flake-inputs` → `main`, titled `chore(deps): update flake inputs`, committing `flake.lock` only, with `delete-branch: true`.

Requirements and deliberate omissions:

- The repository setting *Allow GitHub Actions to create and approve pull requests* must be enabled, otherwise the last step fails with a permission error.
- No auto-merge. An unattended merge of a Neovim-nightly or nixpkgs-unstable bump can break the working environment, and Layer 2 would then push a broken closure to the cache.
- To get a *recorded* CI run on the pull request, push an empty commit to the branch (or swap `GITHUB_TOKEN` for a PAT). The body says so.

### Layer 3a — local prerequisite: the user must be a trusted Nix user

Measured on this Mac: `manuel` is **not** in `trusted-users`, so Nix reports

```
warning: ignoring the client-specified setting 'trusted-public-keys', because it is a restricted setting and you are not a trusted user
```

and silently ignores the substituters that `modules/home-manager/nix-settings` writes. Without the fix below, Layer 2 fills the cache but the laptop still compiles.

Determinate Nix owns `/etc/nix/nix.conf` and includes `/etc/nix/nix.custom.conf` for local additions:

```bash
echo 'trusted-users = root manuel' | sudo tee -a /etc/nix/nix.custom.conf
sudo launchctl kickstart -k system/systems.determinate.nix-daemon
```

Alternative, if the user should stay untrusted: put `extra-substituters` and `extra-trusted-public-keys` into `/etc/nix/nix.custom.conf` instead and drop the home-manager module. That keeps trust with root but moves the setting out of this repository.

On the Linux host the same applies through the system configuration's `nix.settings.trusted-users`, which is not managed here.

### Layer 4 — `cache-gc.yml`, monthly (optional)

`cachix gc` / retention configuration, so the binary cache does not grow without bound. Only relevant with a free Cachix plan and its size limit.

## 4. Secrets and settings

Cachix cache: `thebromo` (public, read key `thebromo.cachix.org-1:Brqme/xyjfgPo1plbGcsdKKPTTJy4i8xnkZ4AvN2Xps=`). The name is hardcoded in `build.yml`, `ci.yml` and `modules/home-manager/nix-settings`; only the write token is a secret.

The `llm-agents.nix` input brings a second cache, `https://cache.numtide.com` (key `niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=`), which is why that input has no `nixpkgs.follows`: its packages are only substitutable when built against upstream's own nixpkgs. It is configured in `modules/home-manager/nix-settings` and in `ci.yml`'s `build-own` job, and deliberately **not** in `build.yml`. The three `extra_nix_config` blocks are duplicated on purpose — the divergence is the safety property, so do not factor them into a shared action.

Price of that omission: the one unrestricted `llm-agents` package in the host closure, `pi`, is an npm build, so `build.yml` compiles it instead of substituting it — measured at roughly 30 s per host. `pi` is also not bit-reproducible (`nix build --rebuild` reports differing output), so the same store path can hold a numtide-built and a `thebromo`-built copy. Both are valid builds of the same input-addressed derivation, so this is a curiosity rather than a problem.

| Name | Purpose | Needed by |
| --- | --- | --- |
| `CACHIX_AUTH_TOKEN` | write access to the `thebromo` cache. Stored in 1Password at `op://Personal/2wlifmtivuwbnvxvaf2gkwrqye/credential` | Layer 2 |

That is the only secret. Set it with:

```bash
op read "op://Personal/2wlifmtivuwbnvxvaf2gkwrqye/credential" \
  | gh secret set CACHIX_AUTH_TOKEN --repo TheBromo/nixos-config
```

The git-crypt key is deliberately *not* in the Actions secret store: in a public repository anyone who can push a workflow could read it, and no workflow needs it (see the `ci-<host>` variant in §3).

Notes:

- `GITHUB_TOKEN` with `contents: write` and `pull-requests: write` is enough for Layer 3; no PAT is needed unless the update PR should itself trigger workflows.
- Both workflows use `permissions: contents: read` and a `concurrency` group, so superseded pushes do not keep two 8.6 GiB builds alive.
- Every action is pinned to a commit SHA — this repository holds the keys to the personal environment.
- Consequence of keeping the key out of CI: the `TX-02` derivation is never built by any workflow. It is covered only by a local `nix flake check` or an actual switch.

## 5. Alternative: Cachix vs. GitHub Actions cache

| Option | Pro | Contra |
| --- | --- | --- |
| **Cachix** (recommended) | Local machines can consume it directly (`make home` becomes a download); no size juggling in the workflow | External service, one more account and token |
| `nix-community/cache-nix-action` (`/nix/store` in the GH Actions cache) | No external service | 10 GiB per-repository limit versus an 8.6 GiB closure; useless for local machines |
| `DeterminateSystems/flakehub-cache-action` | No token juggling, GitHub-native auth | Ties the setup to FlakeHub |

Given that the actual goal is "the laptop should not compile", Cachix is the only option that delivers it.

## 6. Rollout plan

Done:

1. Fixed the existing lint debt and added `statix.toml` (§2.3).
2. Added the `treefmt-nix` input, `modules/formatter`, `modules/lint` and `modules/checks` (§2). Verified locally: `nix fmt`, `nix flake check --no-build --all-systems`, and a build of the `treefmt` and `lint` checks all pass.
3. Added `ci.yml` (Layer 1).
4. Added `build.yml` (Layer 2) against the existing `thebromo` cache, plus `modules/home-manager/nix-settings` on both hosts so the laptops consume it.

5. Set `CACHIX_AUTH_TOKEN` (§4) and added `manuel` to `trusted-users`, so the substituters from `nix-settings` are actually honoured.
6. Added `update.yml` (Layer 3), without auto-merge. Verified: the dispatched run updated 8 inputs, passed the in-job gates against the new lock, and opened PR #9.
7. Merged the pipeline to `main`. `ci.yml` green there (four jobs, 3m34s).
8. Removed the git-crypt dependency from CI: `custom.tx02.enable`, `modules/ci` with the `ci-<host>` variant, and the `GIT_CRYPT_KEY` secret deleted again. The first `build.yml` run had failed in the unlock step, which is now gone entirely.

9. Verified the whole pipeline on `main`. `build.yml` run 35069655787: `manuel-darwin` 25m35s, `manuel` 28m20s, both success, both closures pushed. Spot checks against `https://thebromo.cachix.org`: the two `home-manager-generation` roots and `tree-sitter-cli` answer `200`, the `TX-02` path answers `404` — the licensed font is not in the public cache.

Open:

10. Mark `secrets-guard`, `checks` and `build-own` as required status checks for `main`.
11. Expose the AppImage derivations as `perSystem.packages.*` and add them to `build-own` (§1), so their hashes are verified without a full closure build.
12. Clean up: remove the `zhaw`/`hexagon` targets from `makefile` and the four-host claim in `CLAUDE.md`, or restore the missing host modules.

## 7. What this catches — and what it does not

Caught:

- Nix syntax errors, unknown home-manager options, type errors — Layer 1 `checks`.
- Stale `fetchCargoVendor` hashes today, AppImage hashes after step 11 of §6 — Layer 1 `build-own`.
- Broken flake inputs after an update — Layer 3, which runs the Layer 1 gates itself.
- Formatting drift, dead code, Nix anti-patterns, broken workflow YAML — Layer 1 `checks`.
- Accidentally committed plaintext secrets, or a committed git-crypt key — Layer 1 `secrets-guard`.
- Build failures anywhere in the 8.6 GiB closure, and a host whose target system has no runner mapping — Layer 2.

Not caught:

- The `TX-02` font derivation and `1password-cli`, on purpose: they must not land in a public cache. `claude-code` is in the same category but `ci.yml`'s `build-own` realises it — on Linux only, since that job runs on `ubuntu-latest`.
- Runtime behaviour after activation (does the shell actually start, is the font really visible). CI builds a closure, it does not use a desktop.
- Anything about the `nvim-config` activation hook, which clones an external repository at switch time.
- nixGL-wrapped GUI applications; they need a real GPU, and no host currently imports them.
