if (( $# > 1 )); then
  printf 'Usage: wsswitch [directory]\n' >&2
  exit 2
fi

if (( $# == 1 )); then
  selected=$1
else
  selected=$(
    {
      @find@ "$HOME/Development/" -mindepth 1 -maxdepth 1 -type d
      printf '%s\n' "$HOME/.config/nvim/"
    } | @fzf@
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
  if [[ -z "${HERDR_PANE_ID:-}" ]]; then
    exec @herdr@
  fi
}

start_herdr_server() {
  @nohup@ \
    @env@ -u HERDR_STARTUP_CWD \
    @herdr@ server >/dev/null 2>&1 &
  local server_pid=$!

  for (( attempt = 0; attempt < 150; attempt++ )); do
    if snapshot=$(@herdr@ api snapshot 2>/dev/null); then
      return 0
    fi
    if ! kill -0 "$server_pid" 2>/dev/null; then
      wait "$server_pid" || true
      printf 'Error: failed to start the Herdr server.\n' >&2
      return 1
    fi
    @sleep@ 0.1
  done

  printf 'Error: timed out waiting for the Herdr server.\n' >&2
  return 1
}

selected=$(@realpath@ "$selected")
if ! snapshot=$(@herdr@ api snapshot 2>&1); then
  error_code=$(
    @jq@ -r '.error.code // ""' <<<"$snapshot" 2>/dev/null || true
  )
  if [[ "$error_code" != server_not_running ]] || [[ -n "${HERDR_PANE_ID:-}" ]]; then
    printf '%s\n' "$snapshot" >&2
    exit 1
  fi
  start_herdr_server
fi
workspace_id=$(
  @jq@ -r --arg cwd "$selected" \
    '[.result.snapshot.panes[] | select(.cwd == $cwd) | .workspace_id][0] // ""' \
    <<<"$snapshot"
)

if [[ -n "$workspace_id" ]]; then
  @herdr@ workspace focus "$workspace_id" >/dev/null
  attach_if_outside_herdr
  exit 0
fi

workspace=$(@herdr@ workspace create --cwd "$selected" --focus)
workspace_id=$(@jq@ -er '.result.workspace.workspace_id' <<<"$workspace")
shell_tab_id=$(@jq@ -er '.result.tab.tab_id' <<<"$workspace")
@bootstrap_workspace@ "$selected" "$workspace_id" "$shell_tab_id"
attach_if_outside_herdr
