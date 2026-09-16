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
| `modules/home-manager/TX-02/default.nix` uses `src = "${self}/secrets/TX-02.tar.xz"`, and `secrets/**` is git-crypt encrypted. | Without the git-crypt key, the *evaluation* still succeeds but the *build* fails while unpacking. Full builds require a `GIT_CRYPT_KEY` secret. Pull requests from forks never get secrets, so they must stay eval-only. |
| Own derivations that upstream caches cannot provide: `packages.tree-sitter-cli` (Rust build with a custom `src`), the `TX-02` font, and the AppImage modules (`helium`, `t3code`, `headlamp`). | These are the parts that are actually *our* code and worth building on every PR — they are small compared to the full closure. |
| Only `tree-sitter-cli` is exposed as a flake package. `TX-02` and the AppImage derivations are defined inside module `let` bindings, and no current host imports `helium`, `t3code`, `headlamp`, or `slack`. | To build them in CI, they must first be exposed as `perSystem.packages.*` (the module then consumes `self.packages.<system>.<name>`, exactly like `nvim-config` already does with `tree-sitter-cli`). Without that refactor, nothing verifies their hashes — and the unused AppImage modules are never built at all. |
| Inputs `neovim-nightly-overlay`, `ghostty`, and `herdr` build from source unless their upstream binary caches are configured. | Add the `nix-community` and `ghostty` substituters to the CI Nix config, otherwise a full build compiles Zig and Rust from scratch. |
| The repository is public and git-crypt protected. | A guard job must verify that everything under `secrets/**` is still encrypted in the commit, *before* any unlock step. Never upload the workspace as an artifact after unlocking. |
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
4. **`build-own`** — `nix build .#packages.x86_64-linux.<name>` for every derivation that upstream caches cannot supply. Today that is only `tree-sitter-cli`; after the refactor described in §1 it also covers `TX-02` and the AppImage packages. Small, fast, and it catches the failure mode this repository actually hits: a stale AppImage or `fetchCargoVendor` hash after a version bump. Once `TX-02` is part of this job it needs the git-crypt key, so it must then be skipped for fork pull requests (`if: github.event.pull_request.head.repo.full_name == github.repository`).

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
4. Unlock git-crypt from the `GIT_CRYPT_KEY` secret (base64 of `.git/git-crypt/keys/default`), writing the key to `$RUNNER_TEMP` and deleting it right after.
5. `nix build .#homeConfigurations.<host>.activationPackage --no-link --print-out-paths --print-build-logs`.

Note: never upload build artifacts or the workspace after step 4 — the workspace contains decrypted secrets at that point.

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

| Name | Purpose | Needed by |
| --- | --- | --- |
| `CACHIX_AUTH_TOKEN` | write access to the `thebromo` cache. Stored in 1Password at `op://Personal/2wlifmtivuwbnvxvaf2gkwrqye/credential` | Layer 2 |
| `GIT_CRYPT_KEY` | base64 of `.git/git-crypt/keys/default`, for the `TX-02` font source | Layer 2, and Layer 1 `build-own` once `TX-02` is part of it |

Set them with:

```bash
op read "op://Personal/2wlifmtivuwbnvxvaf2gkwrqye/credential" \
  | gh secret set CACHIX_AUTH_TOKEN --repo TheBromo/nixos-config
base64 -i .git/git-crypt/keys/default \
  | gh secret set GIT_CRYPT_KEY --repo TheBromo/nixos-config
```

Notes:

- `GITHUB_TOKEN` with `contents: write` and `pull-requests: write` is enough for Layer 3; no PAT is needed unless the update PR should itself trigger workflows.
- Both workflows use `permissions: contents: read` and a `concurrency` group, so superseded pushes do not keep two 8.6 GiB builds alive.
- Every action is pinned to a commit SHA — this repository holds the keys to the personal environment.
- `GIT_CRYPT_KEY` is the symmetric key for *all* files under `secrets/`. It lives in the Actions secret store of a public repository, so anyone who can push a workflow to `main` can read it. That is the price for building `TX-02` in CI; the alternative is to drop the `TX-02` module from the CI build and accept an untested font derivation.

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

5. Set the two Actions secrets (§4).
6. Added `update.yml` (Layer 3), without auto-merge.

Open:

7. Add `manuel` to `trusted-users` (§ Layer 3a) — until then the cache is written but not read locally.
8. Enable *Allow GitHub Actions to create and approve pull requests* in the repository settings, for Layer 3.
9. Let the workflows run once (`ci.yml` on a throwaway pull request, `build.yml` and `update.yml` via `workflow_dispatch`), then mark `secrets-guard`, `checks` and `build-own` as required status checks for `main`.
10. Expose `TX-02` and the AppImage derivations as `perSystem.packages.*` and add them to `build-own` (§1), so their hashes are verified without a full closure build.
11. Clean up: remove the `zhaw`/`hexagon` targets from `makefile` and the four-host claim in `CLAUDE.md`, or restore the missing host modules.

## 7. What this catches — and what it does not

Caught:

- Nix syntax errors, unknown home-manager options, type errors — Layer 1 `checks`.
- Stale `fetchCargoVendor` hashes today, AppImage hashes after step 5 of §6 — Layer 1 `build-own`.
- Broken flake inputs after an update — Layer 3, which runs the Layer 1 gates itself.
- Formatting drift, dead code, Nix anti-patterns, broken workflow YAML — Layer 1 `checks`.
- Accidentally committed plaintext secrets, or a committed git-crypt key — Layer 1 `secrets-guard`.
- Build failures anywhere in the 8.6 GiB closure, and a host whose target system has no runner mapping — Layer 2.

Not caught:

- Runtime behaviour after activation (does the shell actually start, is the font really visible). CI builds a closure, it does not use a desktop.
- Anything about the `nvim-config` activation hook, which clones an external repository at switch time.
- nixGL-wrapped GUI applications; they need a real GPU, and no host currently imports them.
