{ self, inputs, ... }:
{
  flake.homeConfigurations."manuel-darwin" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
    extraSpecialArgs = {
      inherit self inputs;
    };
    modules = [
      self.homeModules.manuelDarwinConfiguration
    ];
  };
}
