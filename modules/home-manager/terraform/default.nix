{ ... }:
{
  flake.homeModules.terraform =
    { pkgs, ... }:
    {

      home = {
        packages = [
          pkgs.terraform
          pkgs.google-cloud-sdk
          pkgs.opentofu
          pkgs.dig
          pkgs.just
          pkgs.age
        ];
      };
    };
}
