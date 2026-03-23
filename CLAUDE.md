# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
make up        # nix flake update (uses nom for pretty output)
make hexagon   # home-manager switch for hexagon host (--impure required for nixGL)
make home      # home-manager switch for manuel host
make darwin    # home-manager switch for manuel-darwin host
make zephyrus  # nixos-rebuild switch for zephyrus
make atlas     # nixos-rebuild switch for atlas
```

To check a config without applying: replace `switch` with `build` in the underlying nix command.

## Architecture

This is a flake-based NixOS/home-manager configuration managing multiple hosts across Linux and macOS.

**Hosts:**
- `hexagon` — standalone home-manager on a non-NixOS Linux system (uses `--impure` + nixGL for OpenGL)
- `manuel` — home-manager on Linux
- `manuel-darwin` — home-manager on macOS (aarch64-darwin)
- `zephyrus` — full NixOS system (ASUS laptop)
- `atlas` — full NixOS system (desktop, GNOME + Nvidia)

**Layout:**
- `hosts/` — per-host entry points; each imports from `modules/`
- `modules/home-manager/` — reusable user-environment modules (shell, devtools, git, nvim, tmux, claude, etc.)
- `modules/nixos/` — reusable system-level modules (docker, nvidia, gnome, ssh, etc.)
- `pkgs/` — custom package derivations (info, dvt, dvd, wsswitch, TX-02 font)
- `secrets/` — git-crypt encrypted secrets

**Module import pattern** — hosts use `self` from `specialArgs` to reference modules:
```nix
imports = [ "${self}/modules/home-manager/git" ];
```

**hexagon is the primary development host.** It receives the most modules (paragon robotics package, nixGL, devtools, claude config) and is the one most likely to be modified.

## Key Conventions

- `nixpkgs` follows `nixos-unstable`; `stateVersion = "24.11"` across home-manager configs
- `allowUnfree = true` set in all home-manager configs
- SSH commit signing via Ed25519 key + 1Password agent
- The `hexagon` host passes `nixgl` and `paragon` as `extraSpecialArgs` — use `nixgl.nixGL` wrapper when adding GUI apps to that host
- `modules/home-manager/claude/enforce-lattice.py` is a pre-tool hook that enforces Claude's permission policy; edits to allowed/denied tools belong in `modules/home-manager/claude/default.nix`
