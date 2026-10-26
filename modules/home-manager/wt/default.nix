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

      # Same <repo>/<name> layout under the shared worktree root as the
      # claude, codex and opencode modules, so wsswitch lists them.
      home.file.".config/worktrunk/config.toml".text = ''
        worktree-path = "~/Development/Worktrees/{{ repo }}/{{ branch | sanitize }}"
      '';

      programs.bash.initExtra = ''
        if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
      '';
      programs.zsh.initContent = ''
        if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
      '';
    };
}
