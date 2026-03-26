SHELL := /bin/bash
.PHONY: up zephyrus home

# Update flake
up:
	nix flake update |& nom
atlas:
	nixos-rebuild switch --flake .#atlas |& nom
zephyrus:
	nixos-rebuild switch --flake .#zephyrus |& nom
home:
	nix run nixpkgs#home-manager -- switch --flake .#manuel |& nom
zhaw:
	nix run nixpkgs#home-manager -- switch --flake .#zhaw |& nom
hexagon:
	nix run nixpkgs#home-manager -- switch --impure --flake .#hexagon |& nom
darwin:
	nix run nixpkgs#home-manager -- switch --flake .#manuel-darwin |& nom

