{ ... }:
{
  flake.homeModules.atuin =
    { ... }:
    {
      programs.atuin = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        daemon.enable = false;
        flags = [
          "--disable-up-arrow"
        ];
      };
    };
}
