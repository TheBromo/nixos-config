{
  description = "My personal nixos config";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl.url = github:nix-community/nixos-wsl;
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixos-wsl, ... }:
    let
      root = builtins.toString ./.;

      specialArgs = {
        inherit inputs root;
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
      };
    };
}
