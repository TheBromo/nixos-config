.PHONY: casa wsl up fmt zephyrus

# Alias for casa
casa:
	nixos-rebuild switch --flake '.#casa' |& nom

# Alias for wsl
wsl:
	nixos-rebuild switch --flake .#wsl |& nom

# Update flake
up:
	nix flake update |& nom

# Format nixpkgs
fmt:
	nixpkgs-fmt .

# Alias for zephyrus
zephyrus:
	nixos-rebuild switch --flake .#zephyrus |& nom
