_: {
  flake.homeModules.wsswitch =
    {
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      herdr = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
      neovim = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
      toml = pkgs.formats.toml { };
      renderShellScript =
        path: substitutions:
        builtins.replaceStrings (builtins.attrNames substitutions) (builtins.attrValues substitutions) (
          builtins.readFile path
        );
      bootstrapWorkspace = pkgs.writeShellApplication {
        name = "herdr-workspace-bootstrap";
        text = renderShellScript ./herdr-workspace-bootstrap.sh {
          "@herdr@" = lib.getExe herdr;
          "@jq@" = lib.getExe pkgs.jq;
          "@lazygit@" = lib.getExe pkgs.lazygit;
          "@neovim@" = lib.getExe neovim;
        };
      };
      worktreeEventHook = pkgs.writeShellApplication {
        name = "herdr-worktree-tabs-hook";
        text = renderShellScript ./herdr-worktree-tabs-hook.sh {
          "@bootstrap_workspace@" = lib.getExe bootstrapWorkspace;
          "@jq@" = lib.getExe pkgs.jq;
        };
      };
      worktreePluginManifest = toml.generate "herdr-plugin.toml" {
        id = "strenge.worktree-tabs";
        name = "Worktree workspace tabs";
        version = "0.1.0";
        min_herdr_version = "0.8.0";
        description = "Adds shell, edit, git, and agent tabs to worktree workspaces";
        platforms = [
          "linux"
          "macos"
        ];
        events = [
          {
            on = "worktree.created";
            command = [ "./bin/worktree-event" ];
          }
          {
            on = "worktree.opened";
            command = [ "./bin/worktree-event" ];
          }
        ];
      };
      worktreePlugin = pkgs.runCommand "herdr-worktree-tabs-plugin" { } ''
        mkdir -p "$out/bin"
        cp ${worktreePluginManifest} "$out/herdr-plugin.toml"
        ln -s ${lib.getExe worktreeEventHook} "$out/bin/worktree-event"
      '';
      wsswitch = pkgs.writeShellApplication {
        name = "wsswitch";
        text = renderShellScript ./wsswitch.sh {
          "@bootstrap_workspace@" = lib.getExe bootstrapWorkspace;
          "@env@" = lib.getExe' pkgs.coreutils "env";
          "@find@" = lib.getExe' pkgs.findutils "find";
          "@fzf@" = lib.getExe pkgs.fzf;
          "@herdr@" = lib.getExe herdr;
          "@jq@" = lib.getExe pkgs.jq;
          "@nohup@" = lib.getExe' pkgs.coreutils "nohup";
          "@realpath@" = lib.getExe' pkgs.coreutils "realpath";
          "@sleep@" = lib.getExe' pkgs.coreutils "sleep";
        };
      };
      wsworktree = pkgs.writeShellApplication {
        name = "wsworktree";
        text = renderShellScript ./wsworktree.sh {
          "@git@" = lib.getExe pkgs.git;
          "@herdr@" = lib.getExe herdr;
          "@jq@" = lib.getExe pkgs.jq;
          "@ln@" = lib.getExe' pkgs.coreutils "ln";
          "@mkdir@" = lib.getExe' pkgs.coreutils "mkdir";
        };
      };
    in
    {
      home.packages = [
        bootstrapWorkspace
        wsswitch
        wsworktree
      ];

      home.activation.linkHerdrWorktreeTabsPlugin =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "installHerdrIntegrations"
          ]
          ''
            ${lib.getExe herdr} plugin link ${worktreePlugin} >/dev/null
          '';

      programs.zsh.initContent = lib.mkAfter ''
        function herdr_ws_switch() {
          zle -I
          ${lib.getExe wsswitch}
          zle reset-prompt
        }

        function herdr_ws_worktree() {
          local branch=$BUFFER

          if [[ -z "$branch" ]]; then
            BUFFER=
            zle -M 'Branch:'
            zle -K viins
            if ! zle recursive-edit; then
              zle reset-prompt
              return 1
            fi
            branch=$BUFFER
          fi

          if [[ -n "$branch" ]] && ${lib.getExe wsworktree} "$branch" >/dev/null; then
            BUFFER=
          fi
          zle reset-prompt
        }

        zle -N herdr_ws_switch
        zle -N herdr_ws_worktree
        bindkey '^F' herdr_ws_switch
        bindkey -M viins '^T' herdr_ws_worktree
        bindkey -M vicmd '^T' herdr_ws_worktree
      '';

      programs.bash.initExtra = lib.mkAfter ''
        function herdr_ws_switch() {
          ${lib.getExe wsswitch}
        }

        function herdr_ws_worktree() {
          local branch="$READLINE_LINE"

          if [[ -z "$branch" ]]; then
            read -e -r -p 'Branch: ' branch
          fi

          if [[ -n "$branch" ]] && ${lib.getExe wsworktree} "$branch" >/dev/null; then
            READLINE_LINE=
            READLINE_POINT=0
          fi
        }

        bind -x '"\C-f":herdr_ws_switch'
        bind -x '"\C-t":herdr_ws_worktree'
      '';
    };
}
