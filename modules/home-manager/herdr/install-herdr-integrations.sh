if [[ -d "$HOME/.config/opencode" ]]; then
  herdr integration install opencode
fi

mkdir -p "$HOME/.pi/agent/extensions"
herdr integration install pi
herdr integration install claude
herdr integration install codex
