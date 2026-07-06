SHELL := /bin/bash
.PHONY: up home zhaw hexagon darwin

# Update flake
up:
	nix flake update 2>&1 | nom
home:
	nix run nixpkgs#home-manager -- switch --flake .#manuel 2>&1 | nom
zhaw:
	nix run nixpkgs#home-manager -- switch --flake .#zhaw 2>&1 | nom
hexagon:
	nix run nixpkgs#home-manager -- switch --impure --flake .#hexagon 2>&1 | nom
darwin:
	nix run nixpkgs#home-manager -- switch --flake .#manuel-darwin 2>&1 | nom

