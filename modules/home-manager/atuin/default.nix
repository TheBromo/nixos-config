{ ... }:
{
  flake.homeModules.atuin =
    { ... }:
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
