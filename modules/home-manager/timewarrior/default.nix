{ ... }:
{
  flake.homeModules.timewarrior =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      timew = lib.getExe pkgs.timewarrior;

      # SwiftBar plugin: the first line is the menu bar title, everything after
      # "---" is the dropdown. runtimeInputs pin PATH, so GUI launch works.
      swiftbarPlugin = pkgs.writeShellApplication {
        name = "timewarrior-swiftbar";
        runtimeInputs = [
          pkgs.timewarrior
          pkgs.jq
          pkgs.coreutils
        ];
        text = ''
          midnight=$(date -d 'today 00:00' +%s)
          now=$(date +%s)

          # Sum today's intervals; open interval runs until now, intervals that
          # started before midnight only count from midnight.
          seconds=$(timew export :day 2>/dev/null | jq --argjson midnight "$midnight" --argjson now "$now" '
            def ts: strptime("%Y%m%dT%H%M%SZ") | mktime;
            map(
              ((.start | ts) as $s | (if .end then .end | ts else $now end) as $e
                | ([$e, $now] | min) - ([$s, $midnight] | max))
              | if . > 0 then . else 0 end
            ) | add // 0 | floor
          ' 2>/dev/null || echo 0)

          hours=$((seconds / 3600))
          minutes=$(((seconds % 3600) / 60))
          if [ "$hours" -gt 0 ]; then
            echo "⏱ ''${hours}h ''${minutes}m"
          else
            echo "⏱ ''${minutes}m"
          fi

          echo "---"
          if current=$(timew 2>/dev/null) && echo "$current" | grep -q '^Tracking'; then
            echo "$current" | while IFS= read -r line; do
              echo "$line | font=Menlo size=12"
            done
            echo "Stop | bash=${timew} param1=stop terminal=false refresh=true"
          else
            echo "Not tracking"
            echo "Continue | bash=${timew} param1=continue terminal=false refresh=true"
          fi
          echo "---"
          echo "Today"
          timew summary :day 2>/dev/null | while IFS= read -r line; do
            if [ -n "$line" ]; then
              echo "$line | font=Menlo size=12"
            fi
          done
          echo "Refresh | refresh=true"
        '';
      };

      # SwiftBar resolves symlinks and parses the refresh interval from the
      # resolved file name, so the store file itself must carry the
      # "<name>.<interval>.<ext>" pattern.
      swiftbarPluginFile = pkgs.writeScript "timewarrior.30s.sh" ''
        #!${pkgs.runtimeShell}
        exec ${lib.getExe swiftbarPlugin} "$@"
      '';

      pluginDir = "${config.xdg.configHome}/swiftbar/plugins";
    in
    lib.mkMerge [
      { home.packages = [ pkgs.timewarrior ]; }

      (lib.mkIf pkgs.stdenv.isDarwin {
        home.packages = [ pkgs.swiftbar ];

        # Stable path so SwiftBar's PluginDirectory survives rebuilds.
        xdg.configFile."swiftbar/plugins/timewarrior.30s.sh".source = swiftbarPluginFile;

        targets.darwin.defaults."com.ameba.SwiftBar" = {
          PluginDirectory = pluginDir;
          MakePluginExecutable = false;
        };

        launchd.agents.swiftbar = {
          enable = true;
          config = {
            ProgramArguments = [
              "${pkgs.swiftbar}/Applications/SwiftBar.app/Contents/MacOS/SwiftBar"
            ];
            RunAtLoad = true;
            KeepAlive = false;
            ProcessType = "Interactive";
          };
        };
      })
    ];
}
