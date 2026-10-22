# Rex itself comes from the Rex for Mac app, which puts `rex` on PATH inside
# its terminals. This module manages its config, appearance, and the agent hook that
# `rex skill setup` would add (the skill is self.lib.rexSkill).
_: {
  flake.homeModules.rex =
    { lib, pkgs, ... }:
    let
      # The app's bundled CLI: activation runs without the app's PATH.
      rex = "$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex";
      darkThemeId = (builtins.head (lib.importJSON ./themes.json)).id;
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
        # Rex doesn't watch init.lua.
        reloadRexConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          if [[ -x "${rex}" ]]; then
            "${rex}" --autostart=false config reload >/dev/null || true
          fi
        '';
        # Rex keeps its theme and font in the app's user defaults, not in
        # init.lua. themes.json is what Rex wrote when it migrated the Ghostty
        # cyberdream theme. Only these keys are written: targets.darwin.defaults
        # would `defaults import` and wipe the rest of the domain. Rex reads
        # them on launch, so restart it after a change.
        writeRexAppearance = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run /usr/bin/defaults write com.superlogical.rex Workspace.customThemes -data \
            "$(${lib.getExe pkgs.jq} -c . ${./themes.json} | /usr/bin/xxd -p | tr -d '\n')"
          run /usr/bin/defaults write com.superlogical.rex Workspace.darkThemeID \
            ${lib.escapeShellArg darkThemeId}
          run /usr/bin/defaults write com.superlogical.rex Workspace.terminalFontName "JetBrains Mono"
          run /usr/bin/defaults write com.superlogical.rex Workspace.terminalFontPointSize -float 13
          run /usr/bin/defaults write com.superlogical.rex Workspace.terminalFallbackFontNames \
            -array "Fluent Emoji Color" TX-02
        '';
      };
    };
}
