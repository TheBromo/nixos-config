# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy Commands

```bash
make up          # Update flake inputs (uses nom)
make home        # Switch home-manager for "manuel" (Linux)
make zhaw        # Switch home-manager for "zhaw" (Linux)
make hexagon     # Switch home-manager for "hexagon" (Linux, --impure)
make darwin      # Switch home-manager for "manuel-darwin" (macOS)
make atlas       # NixOS system rebuild (atlas host)
make zephyrus    # NixOS system rebuild (zephyrus host)
```

## Testing with Nix

Build a full home configuration (produces the activation package):
```bash
nix build .#homeConfigurations.manuel.activationPackage
nix build .#homeConfigurations.zhaw.activationPackage
nix build .#homeConfigurations.hexagon.activationPackage --impure
nix build .#homeConfigurations.manuel-darwin.activationPackage
```

Evaluate a home configuration without building (fast syntax/value check):
```bash
nix eval .#homeConfigurations.manuel.activationPackage --apply 'x: "ok"'
```

Evaluate a single homeModule exists:
```bash
nix eval .#homeModules.console --apply 'x: "ok"'
```

List all available homeModules:
```bash
nix eval .#homeModules --apply builtins.attrNames
```

Build an individual package:
```bash
nix build .#packages.x86_64-linux.tree-sitter-cli
```

## Architecture

**Nix Flakes + flake-parts + import-tree**: The flake uses `import-tree` to auto-discover all modules under `./modules/`. Each module exports `flake.*` attributes (typically `flake.homeModules.<name>`).

**Module pattern**: Every home-manager module lives in `modules/home-manager/<name>/default.nix` and exports:
```nix
{ ... }:
{
  flake.homeModules.moduleName = { pkgs, ... }: { ... };
}
```

**Host configurations** in `modules/hosts/<name>/configuration.nix` compose modules and define per-host settings (username, home path, state version, which modules to include).

**Four hosts**: `manuel` (personal Linux), `zhaw` (university Linux), `hexagon` (work Linux, containerized with nixGL), `manuel-darwin` (personal macOS).

**Custom library**: `self.lib.gitModule` is a parameterized factory for git configuration supporting multiple identities, optional commit signing, and 1Password SSH signing.

## Key Integration Points

- **1Password CLI (`op`)**: Used for git commit signing, terraform secrets, SSH agent
- **nixGL**: Wraps GUI applications on the hexagon host (non-NixOS container environment)
- **Git crypt**: Protects encrypted files in the repo
- **Neovim config**: Cloned via home activation hook from a separate repo, not managed inline
- **MCP servers**: Terraform and Atlassian servers configured in the claude module
