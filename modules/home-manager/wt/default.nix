{ ... }:
{
  flake.homeModules.wt =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.worktrunk
      ];

      home.file.".config/wt.toml".text = ''
        [post-start]
        copy = "wt step copy-ignored"
      '';

      programs.zsh.initContent = ''
        if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
      '';
    };
}
