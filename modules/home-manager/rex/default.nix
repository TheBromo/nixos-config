_: {
  flake.homeModules.rex =
    { lib, pkgs, ... }:
    let
      # The app's bundled CLI: activation runs without the app's PATH.
      rex = "$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex";
      darkThemeId = (builtins.head (lib.importJSON ./themes.json)).id;

      # Every setting Rex's settings UI writes to com.superlogical.rex.
      # Machine-local state (window frames, updater, client label, sync
      # records, cached socket route, focus and activity history) stays out.
      settings = {
        "Workspace.darkThemeID" = darkThemeId;
        "Workspace.lightThemeID" = "merino-light";
        "Workspace.interfaceStyle" = "useTheme";
        "Workspace.appIcon" = "default";
        "Workspace.paneDensity" = "comfortable";
        "Workspace.inactivePaneFadeMode" = "both";
        "Workspace.usesPaneGlass" = false;
        "Workspace.usesStandardInactiveWindowPaneStyles" = true;
        "Workspace.sidebarPosition" = "right";
        "Workspace.shellIconTheme" = "themed";
        "Workspace.tabStyle" = "horizontal";
        "Workspace.tabIconColorMode" = "always";
        "Workspace.tabIconTintMode" = "off";
        "Workspace.tabIconCount" = 2;
        "Workspace.terminalFontName" = "JetBrains Mono";
        "Workspace.terminalFontPointSize" = 13.0;
        "Workspace.terminalFallbackFontNames" = [ "TX-02" ];
        "Workspace.terminalCellHeightPercent" = 0.0;
        "Workspace.terminalCursorStyle" = "bar";
        "Workspace.terminalCursorStyleForced" = false;
        "Workspace.terminalFontSmoothing" = false;
        "Workspace.terminalImproveTextContrast" = true;
        "Workspace.terminalUseThemePalette" = false;
        "Workspace.terminalUsesDisplayP3" = true;
        "rex.client.remoteControl" = true;
        "rex.server.automatic-restart-enabled" = true;
        "rex.server.block-plugin-reload-enabled" = false;
        "rex.server.run-mode" = "bundled";
        "rex.server.tailnet-enabled" = true;
        "rex.server.web-client-origin-patterns" = [ "https://rex.superlogical.com" ];
      };

      defaultsArgs =
        value:
        if builtins.isBool value then
          "-bool ${lib.boolToString value}"
        else if builtins.isInt value then
          "-int ${toString value}"
        else if builtins.isFloat value then
          "-float ${toString value}"
        else if builtins.isList value then
          "-array ${lib.escapeShellArgs value}"
        else
          "-string ${lib.escapeShellArg value}";
      sessionStartHook = agent: {
        hooks = [
          {
            type = "command";
            command = "/bin/sh -c 'rex __internal session-start --agent ${agent} 2>/dev/null || true'";
            timeout = 5;
          }
        ];
      };
      installRexAgentHooks = pkgs.writeShellApplication {
        name = "install-rex-agent-hooks";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.jq
        ];
        text = ''
          # Puts the Rex hook first in SessionStart exactly once and keeps
          # every other hook.
          add_hook() {
            local path=$1
            local hook=$2
            local temporary_file

            mkdir -p "''${path%/*}"
            [[ -e "$path" ]] || printf '{}\n' > "$path"
            temporary_file=$(mktemp "$path.XXXXXX")
            jq --argjson hook "$hook" '
              .hooks.SessionStart = [$hook] + [
                (.hooks.SessionStart // [])[]
                | select(any(.hooks[]?; .command | contains("rex __internal session-start")) | not)
              ]
            ' "$path" > "$temporary_file"
            chmod 600 "$temporary_file"
            mv -f "$temporary_file" "$path"
          }

          add_hook "''${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json" ${lib.escapeShellArg (builtins.toJSON (sessionStartHook "claude"))}
          add_hook "''${CODEX_HOME:-$HOME/.codex}/hooks.json" ${lib.escapeShellArg (builtins.toJSON (sessionStartHook "codex"))}
        '';
      };
    in
    {
      xdg.configFile."rex/init.lua".source = ./init.lua;

      home.activation = {
        installRexAgentHooks =
          lib.hm.dag.entryAfter
            [
              "installClaudeSettings"
              "installCodexConfig"
            ]
            ''
              ${lib.getExe installRexAgentHooks}
            '';

        writeRexAppearance = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run /usr/bin/defaults write com.superlogical.rex Workspace.customThemes -data \
            "$(${lib.getExe pkgs.jq} -c . ${./themes.json} | /usr/bin/xxd -p | tr -d '\n')"
          ${lib.concatStrings (
            lib.mapAttrsToList (key: value: ''
              run /usr/bin/defaults write com.superlogical.rex ${lib.escapeShellArg key} ${defaultsArgs value}
            '') settings
          )}
        '';
      };
    };
}
