{ self, inputs, ... }:
{
  flake.homeConfigurations.manuel = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = {
      inherit self inputs;
    };
    modules = [
      self.homeModules.manuelConfiguration
    ];
  };
}
