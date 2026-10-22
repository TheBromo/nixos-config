usage() {
  printf 'Usage: wsswitch [DIRECTORY]\n' >&2
}

rex_bin="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"

worktree_root="$HOME/Development/Worktrees"

# Projects, then every agent worktree as <repo>/<name>.
list_projects() {
  @find@ "$HOME/Development" -mindepth 1 -maxdepth 1 -type d ! -path "$worktree_root"
  if [[ -d "$worktree_root" ]]; then
    @find@ "$worktree_root" -mindepth 2 -maxdepth 2 -type d
  fi
  printf '%s\n' "$HOME/.config/nvim"
}

# Rex sessions don't report a directory, so the label identifies the project.
# Worktrees keep their repo in the label: names like "main" repeat.
session_label() {
  if [[ $1 == "$worktree_root"/*/* ]]; then
    printf '%s\n' "${1#"$worktree_root"/}"
  else
    printf '%s\n' "${1##*/}"
  fi
}

# Prints the ID of the project's session, creating it with a shell tab first.
open_session() {
  local selected
  local label
  local session_id

  if [[ ! -d "$1" ]]; then
    printf "Error: '%s' is not a valid directory.\n" "$1" >&2
    return 1
  fi
  selected=$(@realpath@ "$1")
  label=$(session_label "$selected")

  session_id=$(
    "$rex_bin" ls --json \
      | @jq@ -r --arg label "$label" \
        '[.sessions[] | select(.label == $label) | .session_id][0] // ""'
  )

  if [[ -z "$session_id" ]]; then
    session_id=$(
      "$rex_bin" new "$label" --cwd "$selected" --window shell --json \
        | @jq@ -er '.session_id'
    )
  fi

  printf '%s\n' "$session_id"
}

(( $# <= 1 )) || { usage; exit 2; }
if (( $# == 1 )); then
  selected=$1
else
  selected=$(list_projects | @fzf@) || exit 0
fi
[[ -n "$selected" ]] || exit 0
session_id=$(open_session "$selected")
# The app only takes actions from the CLI with Remote Control on, in Rex's
# settings under Rex Server. Rex's own key actions can't run fzf: the app
# handles no keys while one runs.
"$rex_bin" "do" session.select session_id="$session_id" \
  || printf "Session '%s' is ready; select it in Rex.\n" "$(session_label "$selected")" >&2
