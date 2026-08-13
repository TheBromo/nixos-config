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
      bootstrapWorkspace = pkgs.writeShellApplication {
        name = "herdr-workspace-bootstrap";
        text = ''
          if (( $# != 3 )); then
            printf 'Usage: herdr-workspace-bootstrap DIRECTORY WORKSPACE_ID SHELL_TAB_ID\n' >&2
            exit 2
          fi

          selected=$1
          workspace_id=$2
          shell_tab_id=$3
          herdr_bin="''${HERDR_BIN_PATH:-${lib.getExe herdr}}"

          if [[ ! -d "$selected" ]]; then
            printf "Error: '%s' is not a valid directory.\n" "$selected" >&2
            exit 1
          fi

          tabs=$("$herdr_bin" tab list --workspace "$workspace_id")

          tab_exists() {
            ${lib.getExe pkgs.jq} -e --arg label "$1" \
              '.result.tabs | any(.label == $label)' \
              <<<"$tabs" >/dev/null
          }

          create_command_tab() {
            local label=$1
            local command=$2
            local tab
            local tab_id
            local pane_id

            tab=$(
              "$herdr_bin" tab create \
                --workspace "$workspace_id" \
                --cwd "$selected" \
                --label "$label" \
                --no-focus
            )
            tab_id=$(${lib.getExe pkgs.jq} -er '.result.tab.tab_id' <<<"$tab")
            pane_id=$(${lib.getExe pkgs.jq} -er '.result.root_pane.pane_id' <<<"$tab")
            if ! "$herdr_bin" pane run "$pane_id" "$command" >/dev/null; then
              "$herdr_bin" tab close "$tab_id" >/dev/null || true
              return 1
            fi
          }

          create_agent_tab() {
            local tab
            local tab_id
            local pane_id
            local agent_name

            tab=$(
              "$herdr_bin" tab create \
                --workspace "$workspace_id" \
                --cwd "$selected" \
                --label agent \
                --no-focus
            )
            tab_id=$(${lib.getExe pkgs.jq} -er '.result.tab.tab_id' <<<"$tab")
            pane_id=$(${lib.getExe pkgs.jq} -er '.result.root_pane.pane_id' <<<"$tab")
            agent_name="codex-''${workspace_id,,}"
            if ! "$herdr_bin" agent start "$agent_name" \
              --kind codex \
              --pane "$pane_id" >/dev/null
            then
              "$herdr_bin" tab close "$tab_id" >/dev/null || true
              return 1
            fi
          }

          if ! tab_exists shell; then
            "$herdr_bin" tab rename "$shell_tab_id" shell >/dev/null
          fi

          if ! tab_exists edit; then
            printf -v edit_command '%q %q' ${lib.escapeShellArg (lib.getExe neovim)} "$selected"
            create_command_tab edit "$edit_command"
          fi

          if ! tab_exists git; then
            create_command_tab git ${lib.escapeShellArg (lib.getExe pkgs.lazygit)}
          fi

          if ! tab_exists agent; then
            create_agent_tab
          fi
        '';
      };
      worktreeEventHook = pkgs.writeShellApplication {
        name = "herdr-worktree-tabs-hook";
        text = ''
          : "''${HERDR_PLUGIN_EVENT:?HERDR_PLUGIN_EVENT is required}"
          : "''${HERDR_PLUGIN_EVENT_JSON:?HERDR_PLUGIN_EVENT_JSON is required}"
          : "''${HERDR_PLUGIN_CONTEXT_JSON:?HERDR_PLUGIN_CONTEXT_JSON is required}"
          : "''${HERDR_WORKSPACE_ID:?HERDR_WORKSPACE_ID is required}"
          : "''${HERDR_TAB_ID:?HERDR_TAB_ID is required}"

          if [[ "$HERDR_PLUGIN_EVENT" == worktree.opened ]] \
            && ${lib.getExe pkgs.jq} -e '.data.already_open == true' \
              <<<"$HERDR_PLUGIN_EVENT_JSON" >/dev/null
          then
            exit 0
          fi

          selected=$(
            ${lib.getExe pkgs.jq} -er \
              '.worktree.checkout_path // .workspace_cwd' \
              <<<"$HERDR_PLUGIN_CONTEXT_JSON"
          )
          exec ${lib.getExe bootstrapWorkspace} \
            "$selected" \
            "$HERDR_WORKSPACE_ID" \
            "$HERDR_TAB_ID"
        '';
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
        text = ''
          if (( $# > 1 )); then
            printf 'Usage: wsswitch [directory]\n' >&2
            exit 2
          fi

          if (( $# == 1 )); then
            selected=$1
          else
            selected=$(
              {
                ${lib.getExe' pkgs.findutils "find"} "$HOME/Development/" -mindepth 1 -maxdepth 1 -type d
                printf '%s\n' "$HOME/.config/nvim/"
              } | ${lib.getExe pkgs.fzf}
            ) || exit 0
          fi

          if [[ -z "$selected" ]]; then
            exit 0
          fi

          if [[ ! -d "$selected" ]]; then
            printf "Error: '%s' is not a valid directory.\n" "$selected" >&2
            exit 1
          fi

          attach_if_outside_herdr() {
            if [[ -z "''${HERDR_PANE_ID:-}" ]]; then
              exec ${lib.getExe herdr}
            fi
          }

          selected=$(${lib.getExe' pkgs.coreutils "realpath"} "$selected")
          snapshot=$(${lib.getExe herdr} api snapshot)
          workspace_id=$(
            ${lib.getExe pkgs.jq} -r --arg cwd "$selected" \
              '[.result.snapshot.panes[] | select(.cwd == $cwd) | .workspace_id][0] // ""' \
              <<<"$snapshot"
          )

          if [[ -n "$workspace_id" ]]; then
            ${lib.getExe herdr} workspace focus "$workspace_id" >/dev/null
            attach_if_outside_herdr
            exit 0
          fi

          workspace=$(${lib.getExe herdr} workspace create --cwd "$selected" --focus)
          workspace_id=$(${lib.getExe pkgs.jq} -er '.result.workspace.workspace_id' <<<"$workspace")
          shell_tab_id=$(${lib.getExe pkgs.jq} -er '.result.tab.tab_id' <<<"$workspace")
          ${lib.getExe bootstrapWorkspace} "$selected" "$workspace_id" "$shell_tab_id"
          attach_if_outside_herdr
        '';
      };
      wsworktree = pkgs.writeShellApplication {
        name = "wsworktree";
        text = ''
          usage() {
            printf 'Usage: wsworktree [-r|--remote] BRANCH\n'
          }

          use_remote=false
          branch=

          while (( $# > 0 )); do
            case $1 in
              -r | --remote)
                use_remote=true
                ;;
              -h | --help)
                usage
                exit 0
                ;;
              --)
                shift
                if [[ -n "$branch" ]] || (( $# != 1 )); then
                  usage >&2
                  exit 2
                fi
                branch=$1
                shift
                break
                ;;
              -*)
                printf "Error: unknown option '%s'.\n" "$1" >&2
                usage >&2
                exit 2
                ;;
              *)
                if [[ -n "$branch" ]]; then
                  usage >&2
                  exit 2
                fi
                branch=$1
                ;;
            esac
            shift
          done

          if [[ -z "$branch" ]]; then
            usage >&2
            exit 2
          fi

          repo_root=$(${lib.getExe pkgs.git} rev-parse --show-toplevel 2>/dev/null) || {
            printf 'Error: the current directory is not inside a Git repository.\n' >&2
            exit 1
          }

          validated_branch=$(${lib.getExe pkgs.git} check-ref-format --branch "$branch" 2>/dev/null) || true
          if [[ "$validated_branch" != "$branch" ]]; then
            printf "Error: '%s' is not a valid branch name.\n" "$branch" >&2
            exit 2
          fi

          base_args=()
          remote_base=
          if [[ "$use_remote" == true ]]; then
            remote_ref="refs/remotes/origin/$branch"
            if ${lib.getExe pkgs.git} -C "$repo_root" fetch --quiet --no-tags origin \
              "+refs/heads/$branch:$remote_ref" >/dev/null 2>&1 \
              || ${lib.getExe pkgs.git} -C "$repo_root" show-ref --verify --quiet "$remote_ref"
            then
              remote_base="origin/$branch"
              base_args=(--base "$remote_base")
            else
              printf "Warning: remote branch 'origin/%s' is unavailable; using HEAD.\n" "$branch" >&2
            fi
          fi

          common_git_dir=$(
            ${lib.getExe pkgs.git} -C "$repo_root" rev-parse \
              --path-format=absolute \
              --git-common-dir
          )
          git_crypt_dir="$common_git_dir/git-crypt"

          if [[ -f "$git_crypt_dir/keys/default" ]]; then
            repo_name="''${repo_root##*/}"
            checkout_name="''${branch//\//-}"
            checkout_path="$HOME/.herdr/worktrees/$repo_name/$checkout_name"
            ${lib.getExe' pkgs.coreutils "mkdir"} -p "''${checkout_path%/*}"

            if ${lib.getExe pkgs.git} -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
              ${lib.getExe pkgs.git} -C "$repo_root" worktree add \
                --no-checkout \
                "$checkout_path" \
                "$branch"
            else
              base="''${remote_base:-HEAD}"
              ${lib.getExe pkgs.git} -C "$repo_root" worktree add \
                --no-checkout \
                -b "$branch" \
                "$checkout_path" \
                "$base"
            fi

            worktree_git_dir=$(
              ${lib.getExe pkgs.git} -C "$checkout_path" rev-parse --absolute-git-dir
            )
            ${lib.getExe' pkgs.coreutils "ln"} -s "$git_crypt_dir" "$worktree_git_dir/git-crypt"
            ${lib.getExe pkgs.git} -C "$checkout_path" reset --hard HEAD >/dev/null

            workspace=$(
              ${lib.getExe herdr} worktree open \
                --cwd "$repo_root" \
                --path "$checkout_path" \
                --focus
            )
          else
            workspace=$(
              ${lib.getExe herdr} worktree create \
                --cwd "$repo_root" \
                --branch "$branch" \
                "''${base_args[@]}" \
                --focus
            )
          fi
          selected=$(${lib.getExe pkgs.jq} -er '.result.worktree.path' <<<"$workspace")

          if [[ -n "$remote_base" ]] && ! ${lib.getExe pkgs.git} -C "$selected" branch \
            --set-upstream-to="$remote_base" "$branch" >/dev/null
          then
            printf "Warning: could not set '%s' to track '%s'.\n" "$branch" "$remote_base" >&2
          fi
        '';
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
    };
}
