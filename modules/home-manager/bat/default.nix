{ self, inputs, ... }:
{
  flake.homeModules.bat =
    { pkgs, ... }:
    {

      programs.bat = {
        enable = true;
      };
    };
}
