{ self, inputs, ... }:
{
  flake.homeConfigurations =
    let
      mkDarwinConfiguration =
        extraModules:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = {
            inherit self inputs;
          };
          modules = [ self.homeModules.manuelDarwinConfiguration ] ++ extraModules;
        };
    in
    {
      manuel-darwin = mkDarwinConfiguration [ ];
      manuel-darwin-macbook-pro = mkDarwinConfiguration [
        ({ config, ... }: {
          worktrees.directory = "${config.home.homeDirectory}/Development/Worktrees";
        })
      ];
    };
}
