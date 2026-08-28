: "${HERDR_PLUGIN_EVENT:?HERDR_PLUGIN_EVENT is required}"
: "${HERDR_PLUGIN_EVENT_JSON:?HERDR_PLUGIN_EVENT_JSON is required}"
: "${HERDR_PLUGIN_CONTEXT_JSON:?HERDR_PLUGIN_CONTEXT_JSON is required}"
: "${HERDR_WORKSPACE_ID:?HERDR_WORKSPACE_ID is required}"
: "${HERDR_TAB_ID:?HERDR_TAB_ID is required}"

if [[ "$HERDR_PLUGIN_EVENT" == worktree.opened ]] \
  && @jq@ -e '.data.already_open == true' \
    <<<"$HERDR_PLUGIN_EVENT_JSON" >/dev/null
then
  exit 0
fi

selected=$(
  @jq@ -er \
    '.worktree.checkout_path // .workspace_cwd' \
    <<<"$HERDR_PLUGIN_CONTEXT_JSON"
)
exec @bootstrap_workspace@ \
  "$selected" \
  "$HERDR_WORKSPACE_ID" \
  "$HERDR_TAB_ID"
