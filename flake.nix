{
  description = "My personal nixos config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixgl.url = "github:nix-community/nixGL";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    vicinae.url = "github:vicinaehq/vicinae"; # tell Nixos where to get Vicinae

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paragon = {
      url = "git+ssh://git@gitlab.com/hexagon-gl/hubrobotics/paragon/paragon?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      paragon,
      nixgl,

      vicinae, # enable the Output
      ...
    }:
    let
      lib = nixpkgs.lib;
      specialArgs = {
        inherit self inputs;
      };
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = lib.genAttrs systems;

      hosts = {
        zephyrus = "x86_64-linux";
        atlas = "x86_64-linux";
        hexagon = "x86_64-linux";
        manuel = "x86_64-linux";
        manuel-darwin = "aarch64-darwin";
      };

      baseModules = [ ];
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      nixosConfigurations =
        let
          mkNixos =
            name: modules:
            lib.nixosSystem {
              pkgs = nixpkgs.legacyPackages.${hosts.${name}};
              inherit specialArgs;
              modules = baseModules ++ modules;
            };
        in
        {
          zephyrus = mkNixos "zephyrus" [
            nixos-hardware.nixosModules.asus-zephyrus-ga402
            ./hosts/zephyrus
          ];

          atlas = mkNixos "atlas" [
            ./hosts/atlas
          ];
        };

      homeConfigurations =
        let
          mkHome =
            name: extraArgs: modules:
            home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${hosts.${name}};
              extraSpecialArgs = extraArgs // {
                inherit self inputs;
              };
              modules = modules;
            };
        in
        {
          hexagon = mkHome "hexagon" { inherit nixgl paragon; } [
            vicinae.homeManagerModules.default
            ./hosts/hexagon
          ];

          manuel = mkHome "manuel" { } [
            ./hosts/home-manager
          ];

          manuel-darwin = mkHome "manuel-darwin" { } [
            ./hosts/darwin
          ];
        };
    };
}
