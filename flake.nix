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
      specialArgs = {
        inherit self inputs;
      };
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
      baseModules = [
        ./overlays.nix
        inputs.neovim-nightly-overlay.overlays.default
      ];
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      nixosConfigurations = {
        zephyrus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = baseModules ++ [
            nixos-hardware.nixosModules.asus-zephyrus-ga402
            ./hosts/zephyrus
          ];
        };
	
        atlas = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./hosts/atlas
          ];
        };
      };

      homeConfigurations = {
        "hexagon" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            inherit nixgl;
            inherit self;
            inherit paragon;
            inherit inputs;
          };
          modules = [
            vicinae.homeManagerModules.default
            ./hosts/hexagon
          ];
        };
        "manuel" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            inherit self;
            inherit inputs;
          };
          modules = [
            ./hosts/home-manager
          ];
        };
        "manuel-darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = {
            inherit self;
            inherit inputs;
          };
          modules = [
            ./hosts/darwin
          ];
        };
      };
    };
}
