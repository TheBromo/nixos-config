{
  description = "My personal nixos config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-config = {
      url = "github:thebromo/neovim-config";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixos-wsl, nixos-hardware, neovim-config, ... }:
    let
      root = self;
      specialArgs = {
        inherit inputs root neovim-config ;
      };
      baseModules = [
        ./overlays.nix
      ];
    in
    {
      nixosConfigurations = {
        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = baseModules ++ [
            ./hosts/wsl
            nixos-wsl.nixosModules.wsl
          ];
        };
        zephyrus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = baseModules ++ [
            nixos-hardware.nixosModules.asus-zephyrus-ga402
            ./hosts/zephyrus
          ];
        };
        lunar = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = baseModules ++ [
            ./hosts/lunar
          ];
        };
        casa = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = baseModules ++ [
            ./hosts/casa
          ];
        };
      };
    };
}
