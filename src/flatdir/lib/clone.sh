#!/usr/bin/env bash
set -euo pipefail

flatdir_clone_search() {
  local query="${1:-}"
  flatdir_require_cmd gh
  flatdir_require_cmd fzf

  local selection
  selection="$(gh search repos ${query:+--match=name} ${query:+"$query"} \
    --json fullName,stargazersCount \
    --limit 50 \
    | jq -r '.[] | "\(.fullName)\t\(.stargazersCount)"' \
    | fzf \
      --prompt='clone> ' \
      --height=60% \
      --reverse \
      --delimiter='\t' \
      --with-nth=1 \
      --preview="bash -lc 'source \"${FLATDIR_LIB_DIR}/common.sh\"; flatdir_clone_preview \"\$1\"' _ {1}" \
    )" || true

  [[ -n "$selection" ]] || flatdir_die "no selection"
  local full_name
  full_name="$(printf '%s' "$selection" | cut -f1)"
  echo "git@github.com:${full_name}.git"
}

flatdir_clone() {
  local search=0
  local target=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s) search=1; shift ;;
      *) target="$1"; shift ;;
    esac
  done

  flatdir_require_cmd git

  local root url repo_name dest
  root="$(flatdir_pick_managed_root)"

  if [[ "$search" -eq 1 ]]; then
    url="$(flatdir_clone_search "$target")"
  elif [[ -z "$target" ]]; then
    flatdir_die "usage: flatdir clone [-s] [<git-url | owner/repo | repo>]"
  else
    # Accept:
    #   - full git urls (https://..., git@..., ssh://...)
    #   - owner/repo
    #   - repo (defaults to current GitHub user)
    if [[ "$target" == *"://"* || "$target" == git@* ]]; then
      url="$target"
    elif [[ "$target" == */* ]]; then
      url="git@github.com:${target%.git}.git"
      if ! gh repo view "${target%.git}" >/dev/null 2>&1; then
        echo "repository not found: $target — searching..." >&2
        url="$(flatdir_clone_search "$target")"
      fi
    else
      # repo only => resolve owner from gh
      flatdir_require_cmd gh
      local login
      login="$(gh api user -q .login)" || flatdir_die "failed: gh api user -q .login"
      [[ -n "$login" ]] || flatdir_die "failed: could not determine github login"
      url="git@github.com:${login}/${target%.git}.git"
      if ! gh repo view "${login}/${target%.git}" >/dev/null 2>&1; then
        echo "repository not found: ${login}/${target} — searching..." >&2
        url="$(flatdir_clone_search "$target")"
      fi
    fi
  fi

  # derive repo dir name
  repo_name="$(basename -- "$url")"
  repo_name="${repo_name%.git}"
  [[ -n "$repo_name" ]] || flatdir_die "failed to derive repo name from: $url"

  dest="${root}/${repo_name}"

  # prevent collision with archived path (archive keeps HOME-relative structure)
  local rel archive_conflict
  rel="$(flatdir_relpath_from_home "$dest")"
  archive_conflict="$(flatdir_archive_root)/${rel}"
  if [[ -e "$archive_conflict" ]]; then
    flatdir_die "cannot clone: archived path exists: $archive_conflict"
  fi

  if [[ -e "$dest" ]]; then
    if flatdir_confirm "destination exists. overwrite '$dest'?"; then
      flatdir_safe_rm "$dest"
    else
      flatdir_die "cancelled"
    fi
  fi

  flatdir_run_cmd git clone -- "$url" "$dest"
  echo "cloned: $dest" >&2
}
