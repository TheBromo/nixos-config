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

### Layer 2 — `build.yml`, triggered on pushes to `main`, nightly schedule, and `workflow_dispatch`

Full closure realization plus cache population. This is the "CD" part: after it finishes, a local `make home` or `make darwin` is a download instead of a build.

Matrix, derived from the flake rather than hardcoded:

| Host | Runner |
| --- | --- |
| `manuel` | `ubuntu-latest` |
| `manuel-darwin` | `macos-15` |

Steps per matrix entry:

1. Free disk space (`jlumbroso/free-disk-space` on Ubuntu; prune the preinstalled Xcode/simulator caches on macOS) — required because of the 8.6 GiB closure.
2. Install Nix (`DeterminateSystems/nix-installer-action` or `cachix/install-nix-action`) with extra substituters: `cache.nixos.org`, `nix-community.cachix.org`, `ghostty.cachix.org`, and the repository's own cache.
3. `cachix/cachix-action` with the repository cache and `CACHIX_AUTH_TOKEN`.
4. Unlock git-crypt from the `GIT_CRYPT_KEY` secret (base64 of `.git/git-crypt/keys/default`).
5. `nix build .#homeConfigurations.<host>.activationPackage --no-link --print-out-paths`.
6. Push the closure to Cachix (the `cachix-action` post step does this automatically).

Note: never upload build artifacts or the workspace after step 4 — the workspace contains decrypted secrets at that point.

Optional extra step: `home-manager build --flake .#<host>` inside a container to smoke-test the *activation script* itself. It has limited value here because `nvim-config`'s activation hook clones a Git repository and writes to `$HOME`; treat this as a later addition, not part of the initial concept.

### Layer 3 — `update.yml`, weekly schedule plus `workflow_dispatch`

Dependency maintenance, replacing the manual `make up`.

1. `nix flake update` (or per-input updates, so a broken input is easier to isolate).
2. `peter-evans/create-pull-request` opens a PR titled `chore(deps): update flake inputs`, with the diff of the changed input revisions in the body.
3. Layer 1 runs on that PR as usual.
4. Optional: enable auto-merge when all checks pass. Recommended only after the pipeline has been stable for a few weeks — an unattended merge of a Neovim-nightly bump can break the working environment.

### Layer 4 — `cache-gc.yml`, monthly (optional)

`cachix gc` / retention configuration, so the binary cache does not grow without bound. Only relevant with a free Cachix plan and its size limit.

## 4. Secrets and settings

| Name | Purpose | Needed by |
| --- | --- | --- |
| `GIT_CRYPT_KEY` | base64 of `.git/git-crypt/keys/default`, for the `TX-02` font source | Layers 1 (`build-own`) and 2 |
| `CACHIX_AUTH_TOKEN` | write access to the own binary cache | Layer 2 |
| `CACHIX_CACHE` (variable, not a secret) | cache name | Layers 1 and 2 |

Notes:

- `GITHUB_TOKEN` with `contents: write` and `pull-requests: write` is enough for Layer 3; no PAT is needed unless the update PR should itself trigger workflows.
- Set `concurrency: { group: ${{ github.workflow }}-${{ github.ref }}, cancel-in-progress: true }` so superseded pushes do not keep two 8.6 GiB builds alive.
- Pin every action to a commit SHA — this repository holds the keys to the personal environment.

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

Open:

4. Let `ci.yml` run once on a throwaway pull request, then mark `secrets-guard`, `checks` and `build-own` as required status checks for `main`.
5. Expose `TX-02` and the AppImage derivations as `perSystem.packages.*` and add them to `build-own` (§1), so their hashes are verified.
6. Add `build.yml` plus the Cachix cache (Layer 2). Add the cache as a substituter to the local configurations, so the laptops actually profit.
7. Add `update.yml` (Layer 3), initially without auto-merge.
8. Clean up: remove the `zhaw`/`hexagon` targets from `makefile` and the four-host claim in `CLAUDE.md`, or restore the missing host modules.

## 7. What this catches — and what it does not

Caught:

- Nix syntax errors, unknown home-manager options, type errors — Layer 1 `checks`.
- Stale `fetchCargoVendor` hashes today, AppImage hashes after step 5 of §6 — Layer 1 `build-own`.
- Broken flake inputs after an update — Layer 3 plus Layer 1.
- Formatting drift, dead code, Nix anti-patterns, broken workflow YAML — Layer 1 `checks`.
- Accidentally committed plaintext secrets, or a committed git-crypt key — Layer 1 `secrets-guard`.
- Build failures anywhere in the 8.6 GiB closure — Layer 2.

Not caught:

- Runtime behaviour after activation (does the shell actually start, is the font really visible). CI builds a closure, it does not use a desktop.
- Anything about the `nvim-config` activation hook, which clones an external repository at switch time.
- nixGL-wrapped GUI applications; they need a real GPU, and no host currently imports them.
