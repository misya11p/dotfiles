#!/usr/bin/env bash
set -euo pipefail

flatdir_clone() {
  local target
  target="${1:-}"
  [[ -n "$target" ]] || flatdir_die "usage: flatdir clone <git-url | owner/repo | repo>"

  flatdir_require_cmd git

  local root url repo_name dest
  root="$(flatdir_pick_managed_root)"

  # Accept:
  #   - full git urls (https://..., git@..., ssh://...)
  #   - owner/repo
  #   - repo (defaults to current GitHub user)
  if [[ "$target" == *"://"* || "$target" == git@* ]]; then
    url="$target"
  elif [[ "$target" == */* ]]; then
    # treat as owner/repo
    url="git@github.com:${target%.git}.git"
  else
    # repo only => resolve owner from gh
    flatdir_require_cmd gh
    local login
    login="$(gh api user -q .login)" || flatdir_die "failed: gh api user -q .login"
    [[ -n "$login" ]] || flatdir_die "failed: could not determine github login"
    url="git@github.com:${login}/${target%.git}.git"
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
