{ self, inputs, ... }:
{
  flake.homeConfigurations.hexagon = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = {
      inherit self inputs;
      nixgl = inputs.nixgl;
      paragon = inputs.paragon;
    };
    modules = [
      self.homeModules.hexagonConfiguration
    ];
  };
}
