{ ... }:
{
  flake.homeModules.console =
    { ... }:
    {

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = false;
        syntaxHighlighting.enable = true;
        defaultKeymap = "viins";

        shellAliases = {
          ll = "ls -alF";
          la = "ls -A";
          l = "ls -CF";
        };

        initContent = ''
          export PATH="$HOME/.local/bin:$PATH"
          export PATH=$HOME/.opencode/bin:$PATH
        '';
      };
    };
}
