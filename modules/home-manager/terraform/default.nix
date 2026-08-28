{ ... }:
{
  flake.homeModules.terraform =
    { pkgs, ... }:
    {

      home = {
        packages = [
          pkgs.terraform
          pkgs.azure-cli
          pkgs.opentofu
          pkgs.just
          pkgs.age
        ];
      };
    };
}
