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
      # Work around nixpkgs #485682 until options documentation preserves store context.
      manual.manpages.enable = false;

      home = {
        sessionPath = lib.mkBefore [
          "$HOME/.opencode/bin"
          "$HOME/.local/bin"
        ];
        sessionVariables = {
          FZF_ALT_C_COMMAND = lib.getExe ripgrepDirectories;
          FZF_CTRL_T_COMMAND = ripgrepFileCommand;
          FZF_DEFAULT_COMMAND = ripgrepFileCommand;
          RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/config";
        };
        shellAliases = {
          l = "ls -CF";
          la = "ls -A";
          ll = "ls -alF";
        };
      };

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
        enableBashIntegration = true;
        enableZshIntegration = true;
        defaultCommand = ripgrepFileCommand;
        fileWidget.command = ripgrepFileCommand;
        changeDirWidget.command = lib.getExe ripgrepDirectories;
        historyWidget.command = "";
      };

      programs.bash = {
        enable = true;
        enableCompletion = true;
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = false;
        syntaxHighlighting = {
          enable = true;
          styles.comment = "fg=#8e8d8d";
        };
        defaultKeymap = "viins";
      };
    };
}
