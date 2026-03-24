{ self, inputs, ... }:
{
  flake.homeModules.atuin =
    { pkgs, ... }:
    {

      programs.atuin = {
        enable = true;
        enableZshIntegration = true;
        daemon.enable = false;
        flags = [
          "--disable-up-arrow"
        ];
      };
    };
}
