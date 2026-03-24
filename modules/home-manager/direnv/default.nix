{ self, inputs, ... }:
{
  flake.homeModules.direnv =
    { pkgs, ... }:
    {

      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };
}
