# WorktreeCreate hook: Claude Code has no setting for where worktrees go, so
# this creates them under the shared worktree root. Claude reads the path from
# the last line of stdout; everything else goes to stderr. Without a
# WorktreeRemove hook, Claude removes the worktree with `git worktree remove`.
input=$(cat)
cwd=$(jq -er '.cwd' <<<"$input")
name=$(jq -er '.name' <<<"$input")

repo_root=$(git -C "$cwd" rev-parse --show-toplevel)
path="@worktree_root@/${repo_root##*/}/$name"
branch="worktree-$name"

mkdir -p "${path%/*}"
if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
  git -C "$repo_root" worktree add "$path" "$branch" >&2
else
  git -C "$repo_root" worktree add -b "$branch" "$path" >&2
fi
printf '%s\n' "$path"
