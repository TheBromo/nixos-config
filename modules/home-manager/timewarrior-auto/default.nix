{ self, inputs, ... }:
{
  flake.homeModules.timewarriorAuto =
    { pkgs, ... }:
    let
      timew = "${pkgs.timewarrior}/bin/timew";
      notify = "${pkgs.libnotify}/bin/notify-send";

      timewAuto = pkgs.writeShellScript "timew-auto" ''
        set -euo pipefail

        EVENT="$1"
        STATE_DIR="$HOME/.local/share/timew-auto"
        STATE_FILE="$STATE_DIR/started_today"
        LOG="$STATE_DIR/timew-auto.log"
        TODAY=$(date +%Y-%m-%d)

        mkdir -p "$STATE_DIR"
        echo "$(date -Iseconds) event=$EVENT" >> "$LOG"

        case "$EVENT" in
          login)
            if [ ! -f "$STATE_FILE" ] || [ "$(cat "$STATE_FILE")" != "$TODAY" ]; then
              echo "$TODAY" > "$STATE_FILE"
              ${timew} start >> "$LOG" 2>&1 || true
              echo "$(date -Iseconds) timew start (first login)" >> "$LOG"
              ${notify} "Timewarrior" "Started tracking" || true
            else
              ${timew} continue >> "$LOG" 2>&1 || true
              echo "$(date -Iseconds) timew continue (login after restart)" >> "$LOG"
              ${notify} "Timewarrior" "Resumed tracking" || true
            fi
            ;;
          lock|logout)
            ${timew} stop >> "$LOG" 2>&1 || true
            echo "$(date -Iseconds) timew stop ($EVENT)" >> "$LOG"
            ${notify} "Timewarrior" "Stopped tracking" || true
            ;;
          unlock)
            ${timew} continue >> "$LOG" 2>&1 || true
            echo "$(date -Iseconds) timew continue (unlock)" >> "$LOG"
            ${notify} "Timewarrior" "Resumed tracking" || true
            ;;
        esac
      '';

      jiraTagger = pkgs.writeShellScript "timew-jira-tag" ''
        set -euo pipefail

        TOKEN_FILE="$HOME/.config/jira/api-token"
        STATE_DIR="$HOME/.local/share/timew-auto"
        LOG="$STATE_DIR/timew-auto.log"
        EMAIL="manuel.strenge-ext@hexagon.com"
        JIRA_BASE="https://hexagon-robotics.atlassian.net"

        mkdir -p "$STATE_DIR"

        if [ ! -f "$TOKEN_FILE" ]; then
          echo "$(date -Iseconds) jira-tag: no token at $TOKEN_FILE, skipping" >> "$LOG"
          exit 0
        fi

        TOKEN=$(cat "$TOKEN_FILE")
        AUTH=$(printf '%s:%s' "$EMAIL" "$TOKEN" | ${pkgs.coreutils}/bin/base64 -w0)

        JQL="assignee = currentUser() AND status WAS \"In Progress\" DURING (\"-1h\", \"-0d\")"

        echo "$(date -Iseconds) jira-tag: querying Jira" >> "$LOG"

        TICKETS=$(${pkgs.curl}/bin/curl -sf \
          -G \
          -H "Authorization: Basic $AUTH" \
          -H "Content-Type: application/json" \
          --data-urlencode "jql=$JQL" \
          --data-urlencode "fields=key" \
          --data-urlencode "maxResults=50" \
          "$JIRA_BASE/rest/api/3/search/jql" \
          | ${pkgs.jq}/bin/jq -r '.issues[].key') || {
            echo "$(date -Iseconds) jira-tag: Jira API call failed" >> "$LOG"
            exit 1
          }

        if [ -z "$TICKETS" ]; then
          echo "$(date -Iseconds) jira-tag: no in-progress tickets found" >> "$LOG"
          exit 0
        fi

        for TICKET in $TICKETS; do
          echo "$(date -Iseconds) jira-tag: timew tag @1 $TICKET" >> "$LOG"
          ${timew} tag @1 "$TICKET" >> "$LOG" 2>&1 || true
        done

        TICKET_LIST=$(echo "$TICKETS" | tr '\n' ' ')
        ${notify} "Timewarrior" "Tagged: $TICKET_LIST" || true
      '';

      dbusMonitor = pkgs.writeShellScript "timew-dbus-monitor" ''
        ${pkgs.glib}/bin/gdbus monitor \
          --session \
          --dest org.gnome.ScreenSaver \
          --object-path /org/gnome/ScreenSaver \
        | while IFS= read -r line; do
            case "$line" in
              *ActiveChanged*true*)  ${timewAuto} lock   ;;
              *ActiveChanged*false*) ${timewAuto} unlock ;;
            esac
          done
      '';
    in
    {
      home.packages = [ pkgs.timewarrior ];

      systemd.user.services.timew-auto-login = {
        Unit = {
          Description = "Timewarrior auto-start on first login";
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${timewAuto} login";
          ExecStop = "${timewAuto} logout";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      systemd.user.services.timew-dbus-monitor = {
        Unit = {
          Description = "Timewarrior screen lock/unlock monitor";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${dbusMonitor}";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      systemd.user.services.timew-jira-tag = {
        Unit = {
          Description = "Tag timewarrior intervals with Jira in-progress tickets";
          After = [ "network-online.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${jiraTagger}";
        };
      };

      systemd.user.timers.timew-jira-tag = {
        Unit = {
          Description = "Hourly Jira → timewarrior tagger";
        };
        Timer = {
          OnCalendar = "hourly";
          Persistent = true;
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
}
