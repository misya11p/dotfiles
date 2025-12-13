#!/usr/bin/env bash
set -euo pipefail

flatdir_clone() {
  local url
  url="${1:-}"
  [[ -n "$url" ]] || flatdir_die "usage: flatdir clone <git-url>"

  flatdir_require_cmd git

  local root repo_name dest
  root="$(flatdir_pick_managed_root)"

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
      flatdir_safe_rm_rf "$dest"
    else
      flatdir_die "cancelled"
    fi
  fi

  flatdir_run_cmd git clone -- "$url" "$dest"
  echo "cloned: $dest" >&2
}
