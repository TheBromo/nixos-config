.PHONY: up zephyrus home

# Update flake
up:
	nix flake update |& nom

atlas:
	nixos-rebuild switch --flake .#atlas #|& nom
zephyrus:
	nixos-rebuild switch --flake .#zephyrus |& nom

home:
	nix run nixpkgs#home-manager -- switch --flake .#manuel

hexagon:
	nix run nixpkgs#home-manager -- switch --impure --flake .#hexagon

darwin:
	nix run nixpkgs#home-manager -- switch --flake .#manuel-darwin

