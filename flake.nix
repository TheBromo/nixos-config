{
  description = "My personal nixos config";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-config = {
      url = "github:thebromo/neovim-config";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    hyprland.url = "github:hyprwm/Hyprland";
    nixos-wsl.url = github:nix-community/nixos-wsl;
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixos-wsl, neovim-config, home-manager, ... }:
    let
      root = builtins.toString ./.;
      specialArgs = {
        inherit inputs root neovim-config;
      };
    in
    {
      nixosConfigurations = {
        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./hosts/wsl
            nixos-wsl.nixosModules.wsl
          ];
        };
        zephyrus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./hosts/zephyrus
          ];
        };

        casa = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./hosts/casa
          ];
        };
      };
      homeConfigurations = {
        thebromo = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = specialArgs;
          modules = [
            ./hosts/aeternus/default.nix
          ];
        };
      };
    };
}
