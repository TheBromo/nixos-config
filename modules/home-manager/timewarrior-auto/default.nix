{ pkgs, ... }:
let
  timew = "${pkgs.timewarrior}/bin/timew";

  # Main event handler script
  timewAuto = pkgs.writeShellScript "timew-auto" ''
    set -euo pipefail

    EVENT="$1"
    HOUR=$(date +%H)
    MINUTE=$(date +%M)
    NOW=$(( 10#$HOUR * 60 + 10#$MINUTE ))

    LUNCH_START=$(( 11 * 60 + 30 ))  # 11:30
    LUNCH_END=$(( 13 * 60 + 30 ))    # 13:30
    EOD=$(( 15 * 60 ))               # 15:00

    STATE_DIR="$HOME/.local/share/timew-auto"
    STATE_FILE="$STATE_DIR/started_today"
    LOG="$STATE_DIR/timew-auto.log"
    TODAY=$(date +%Y-%m-%d)

    mkdir -p "$STATE_DIR"
    echo "$(date -Iseconds) event=$EVENT now=''${NOW}min" >> "$LOG"

    case "$EVENT" in
      login)
        # Only start once per day
        if [ ! -f "$STATE_FILE" ] || [ "$(cat "$STATE_FILE")" != "$TODAY" ]; then
          echo "$TODAY" > "$STATE_FILE"
          ${timew} start >> "$LOG" 2>&1 || true
          echo "$(date -Iseconds) timew start (first login)" >> "$LOG"
        fi
        ;;
      lock)
        # Lunch window: stop tracking
        if [ "$NOW" -ge "$LUNCH_START" ] && [ "$NOW" -le "$LUNCH_END" ]; then
          ${timew} stop >> "$LOG" 2>&1 || true
          echo "$(date -Iseconds) timew stop (lunch lock)" >> "$LOG"
        # End of day: stop tracking
        elif [ "$NOW" -ge "$EOD" ]; then
          ${timew} stop >> "$LOG" 2>&1 || true
          echo "$(date -Iseconds) timew stop (EOD lock)" >> "$LOG"
        fi
        ;;
      unlock)
        # Lunch window: resume tracking
        if [ "$NOW" -ge "$LUNCH_START" ] && [ "$NOW" -le "$LUNCH_END" ]; then
          ${timew} continue >> "$LOG" 2>&1 || true
          echo "$(date -Iseconds) timew continue (lunch unlock)" >> "$LOG"
        fi
        ;;
      logout)
        # End of day: stop tracking on logout/shutdown
        if [ "$NOW" -ge "$EOD" ]; then
          ${timew} stop >> "$LOG" 2>&1 || true
          echo "$(date -Iseconds) timew stop (logout)" >> "$LOG"
        fi
        ;;
    esac
  '';

  # Jira → timewarrior tagger
  # Reads ~/.config/jira/api-token (plain Jira API token).
  # Queries for tickets assigned to the user that were "In Progress" in the last 24 h
  # and tags yesterday's timewarrior intervals with each ticket key.
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

    JQL="assignee = currentUser() AND status WAS \"In Progress\" DURING (\"-1d\", \"-0d\")"

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
  '';

  # D-Bus monitor that listens for GNOME screen lock/unlock signals
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

  # Run timew start on first graphical login of the day;
  # run timew stop (if after 15:00) when the session ends.
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

  # Watch GNOME ScreenSaver D-Bus signal for lock/unlock events
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

  # Tag yesterday's timewarrior intervals with Jira ticket keys at 10:00
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
      Description = "Daily Jira → timewarrior tagger at 10:00";
    };
    Timer = {
      OnCalendar = "*-*-* 10:00:00";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
