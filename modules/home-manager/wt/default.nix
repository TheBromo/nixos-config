{ ... }:
{
  flake.homeModules.wt =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.worktrees.directory = lib.mkOption {
        type = lib.types.addCheck lib.types.str (lib.hasPrefix "/");
        default = "${config.home.homeDirectory}/Development/Worktrees";
        description = "Absolute parent directory for agent and command-line Git worktrees.";
      };

      config = {
        home.packages = [
          pkgs.worktrunk
        ];

        home.file.".config/wt.toml".text = ''
          [post-start]
          copy = "wt step copy-ignored"
        '';

        home.file.".config/worktrunk/config.toml".source =
          (pkgs.formats.toml { }).generate "worktrunk-config.toml"
            { worktree-path = "${config.worktrees.directory}/{{ repo }}/{{ branch | sanitize }}"; };

        programs.bash.initExtra = ''
          if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
        '';
        programs.zsh.initContent = ''
          if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
        '';
      };
    };
}
