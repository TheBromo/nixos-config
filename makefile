SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.PHONY: up home zhaw hexagon darwin

# Update flake
up:
	nix flake update 2>&1 | nom
home:
	nix run nixpkgs#home-manager -- switch --flake .#manuel 2>&1 | nom
darwin:
	nix run nixpkgs#home-manager -- switch --flake .#manuel-darwin 2>&1 | nom
