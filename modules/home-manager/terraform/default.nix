{ ... }:
{
  flake.homeModules.terraform =
    { pkgs, ... }:
    {

      home = {
        packages = [
          pkgs.terraform
          pkgs.azure-cli
          pkgs.google-cloud-sdk
          pkgs.opentofu
          pkgs.dig
          pkgs.just
          pkgs.age
        ];
      };
    };
}
