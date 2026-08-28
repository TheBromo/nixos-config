if (( $# != 3 )); then
  printf 'Usage: herdr-workspace-bootstrap DIRECTORY WORKSPACE_ID SHELL_TAB_ID\n' >&2
  exit 2
fi

selected=$1
workspace_id=$2
shell_tab_id=$3
herdr_bin="${HERDR_BIN_PATH:-@herdr@}"

if [[ ! -d "$selected" ]]; then
  printf "Error: '%s' is not a valid directory.\n" "$selected" >&2
  exit 1
fi

tabs=$("$herdr_bin" tab list --workspace "$workspace_id")

tab_exists() {
  @jq@ -e --arg label "$1" \
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
  tab_id=$(@jq@ -er '.result.tab.tab_id' <<<"$tab")
  pane_id=$(@jq@ -er '.result.root_pane.pane_id' <<<"$tab")
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
  tab_id=$(@jq@ -er '.result.tab.tab_id' <<<"$tab")
  pane_id=$(@jq@ -er '.result.root_pane.pane_id' <<<"$tab")
  agent_name="codex-${workspace_id,,}"
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
  printf -v edit_command '%q %q' @neovim@ "$selected"
  create_command_tab edit "$edit_command"
fi

if ! tab_exists git; then
  create_command_tab git @lazygit@
fi

if ! tab_exists agent; then
  create_agent_tab
fi
