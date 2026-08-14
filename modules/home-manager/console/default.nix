{ ... }:
{
  flake.homeModules.console =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      ripgrepFileCommand = lib.concatStringsSep " " (
        [
          (lib.getExe pkgs.ripgrep)
          "--files"
          "--hidden"
        ]
        ++
          lib.concatMap
            (directory: [
              "--glob"
              (lib.escapeShellArg "!**/${directory}")
              "--glob"
              (lib.escapeShellArg "!**/${directory}/**")
            ])
            [
              ".git"
              ".devenv"
              ".direnv"
              "node_modules"
            ]
      );
      ripgrepDirectories = pkgs.writeShellApplication {
        name = "fzf-ripgrep-directories";
        text = ''
          ${ripgrepFileCommand} --null \
            | ${lib.getExe pkgs.gawk} -v 'RS=\0' -F/ '
                NF > 1 {
                  directory = $1
                  print directory
                  for (component = 2; component < NF; component++) {
                    directory = directory "/" $component
                    print directory
                  }
                }
              ' \
            | ${lib.getExe' pkgs.coreutils "sort"} --unique
        '';
      };
    in
    {
      home.sessionVariables.RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/config";

      xdg.configFile."ripgrep/config".text = ''
        --glob=!**/.devenv
        --glob=!**/.devenv/**
        --glob=!**/.direnv
        --glob=!**/.direnv/**
        --glob=!**/node_modules
        --glob=!**/node_modules/**
      '';

      programs.btop = {
        enable = true;
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultCommand = ripgrepFileCommand;
        fileWidget.command = ripgrepFileCommand;
        changeDirWidget.command = lib.getExe ripgrepDirectories;
        historyWidget.command = "";
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
          export FZF_ALT_C_COMMAND=${lib.escapeShellArg (lib.getExe ripgrepDirectories)}
          export FZF_CTRL_T_COMMAND=${lib.escapeShellArg ripgrepFileCommand}
          export FZF_DEFAULT_COMMAND=${lib.escapeShellArg ripgrepFileCommand}

          export PATH="$HOME/.local/bin:$PATH"
          export PATH=$HOME/.opencode/bin:$PATH
        '';
      };
    };
}
