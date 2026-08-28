usage() {
  printf 'Usage: wsworktree [-r|--remote] BRANCH\n'
}

use_remote=false
branch=

while (( $# > 0 )); do
  case $1 in
    -r | --remote)
      use_remote=true
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      if [[ -n "$branch" ]] || (( $# != 1 )); then
        usage >&2
        exit 2
      fi
      branch=$1
      shift
      break
      ;;
    -*)
      printf "Error: unknown option '%s'.\n" "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ -n "$branch" ]]; then
        usage >&2
        exit 2
      fi
      branch=$1
      ;;
  esac
  shift
done

if [[ -z "$branch" ]]; then
  usage >&2
  exit 2
fi

repo_root=$(@git@ rev-parse --show-toplevel 2>/dev/null) || {
  printf 'Error: the current directory is not inside a Git repository.\n' >&2
  exit 1
}

validated_branch=$(@git@ check-ref-format --branch "$branch" 2>/dev/null) || true
if [[ "$validated_branch" != "$branch" ]]; then
  printf "Error: '%s' is not a valid branch name.\n" "$branch" >&2
  exit 2
fi

base_args=()
remote_base=
if [[ "$use_remote" == true ]]; then
  remote_ref="refs/remotes/origin/$branch"
  if @git@ -C "$repo_root" fetch --quiet --no-tags origin \
    "+refs/heads/$branch:$remote_ref" >/dev/null 2>&1 \
    || @git@ -C "$repo_root" show-ref --verify --quiet "$remote_ref"
  then
    remote_base="origin/$branch"
    base_args=(--base "$remote_base")
  else
    printf "Warning: remote branch 'origin/%s' is unavailable; using HEAD.\n" "$branch" >&2
  fi
fi

common_git_dir=$(
  @git@ -C "$repo_root" rev-parse \
    --path-format=absolute \
    --git-common-dir
)
git_crypt_dir="$common_git_dir/git-crypt"

if [[ -f "$git_crypt_dir/keys/default" ]]; then
  repo_name="${repo_root##*/}"
  checkout_name="${branch//\//-}"
  checkout_path="$HOME/.herdr/worktrees/$repo_name/$checkout_name"
  @mkdir@ -p "${checkout_path%/*}"

  if @git@ -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
    @git@ -C "$repo_root" worktree add \
      --no-checkout \
      "$checkout_path" \
      "$branch"
  else
    base="${remote_base:-HEAD}"
    @git@ -C "$repo_root" worktree add \
      --no-checkout \
      -b "$branch" \
      "$checkout_path" \
      "$base"
  fi

  worktree_git_dir=$(
    @git@ -C "$checkout_path" rev-parse --absolute-git-dir
  )
  @ln@ -s "$git_crypt_dir" "$worktree_git_dir/git-crypt"
  @git@ -C "$checkout_path" reset --hard HEAD >/dev/null

  workspace=$(
    @herdr@ worktree open \
      --cwd "$repo_root" \
      --path "$checkout_path" \
      --focus
  )
else
  workspace=$(
    @herdr@ worktree create \
      --cwd "$repo_root" \
      --branch "$branch" \
      "${base_args[@]}" \
      --focus
  )
fi
selected=$(@jq@ -er '.result.worktree.path' <<<"$workspace")

if [[ -n "$remote_base" ]] && ! @git@ -C "$selected" branch \
  --set-upstream-to="$remote_base" "$branch" >/dev/null
then
  printf "Warning: could not set '%s' to track '%s'.\n" "$branch" "$remote_base" >&2
fi
