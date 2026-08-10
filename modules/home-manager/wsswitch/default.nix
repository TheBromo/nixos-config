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

          selected=$(${lib.getExe' pkgs.coreutils "realpath"} "$selected")
          snapshot=$(${lib.getExe herdr} api snapshot)
          workspace_id=$(
            ${lib.getExe pkgs.jq} -r --arg cwd "$selected" \
              '[.result.snapshot.panes[] | select(.cwd == $cwd) | .workspace_id][0] // ""' \
              <<<"$snapshot"
          )

          if [[ -n "$workspace_id" ]]; then
            exec ${lib.getExe herdr} workspace focus "$workspace_id"
          fi

          workspace=$(${lib.getExe herdr} workspace create --cwd "$selected" --focus)
          workspace_id=$(${lib.getExe pkgs.jq} -er '.result.workspace.workspace_id' <<<"$workspace")
          shell_tab_id=$(${lib.getExe pkgs.jq} -er '.result.tab.tab_id' <<<"$workspace")
          ${lib.getExe herdr} tab rename "$shell_tab_id" shell >/dev/null

          edit_tab=$(
            ${lib.getExe herdr} tab create \
              --workspace "$workspace_id" \
              --cwd "$selected" \
              --label edit \
              --no-focus
          )
          edit_pane_id=$(${lib.getExe pkgs.jq} -er '.result.root_pane.pane_id' <<<"$edit_tab")
          printf -v edit_command '%q %q' ${lib.escapeShellArg (lib.getExe neovim)} "$selected"
          ${lib.getExe herdr} pane run "$edit_pane_id" "$edit_command" >/dev/null

          agent_tab=$(
            ${lib.getExe herdr} tab create \
              --workspace "$workspace_id" \
              --cwd "$selected" \
              --label agent \
              --no-focus
          )
          agent_pane_id=$(${lib.getExe pkgs.jq} -er '.result.root_pane.pane_id' <<<"$agent_tab")
          agent_name="codex-''${workspace_id,,}"
          ${lib.getExe herdr} agent start "$agent_name" \
            --kind codex \
            --pane "$agent_pane_id" >/dev/null
        '';
      };
    in
    {
      home.packages = [
        wsswitch
      ];

      programs.zsh.initContent = lib.mkAfter ''
        function herdr_ws_switch() {
          ${lib.getExe wsswitch} >/dev/null
          zle reset-prompt
        }

        zle -N herdr_ws_switch
        bindkey '^F' herdr_ws_switch
      '';
    };
}
