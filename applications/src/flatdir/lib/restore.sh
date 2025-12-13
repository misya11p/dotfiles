#!/usr/bin/env bash
set -euo pipefail

flatdir_restore() {
  flatdir_require_cmd fzf

  local archive_root selection rel dest
  archive_root="$(flatdir_archive_root)"

  [[ -d "$archive_root" ]] || flatdir_die "archive directory not found: $archive_root"

  # list directories that have marker
  selection="$({
    find "$archive_root" -type f -name '.flatdir_archived' -print 2>/dev/null | sed 's#/.flatdir_archived$##'
  } | fzf --prompt='archive> ' --height=60% --reverse)" || true

  [[ -n "$selection" ]] || flatdir_die "no selection"
  [[ -d "$selection" ]] || flatdir_die "not a directory: $selection"

  # compute relpath from archive_root without relying on sed escaping
  local selection_abs archive_abs
  if command -v realpath >/dev/null 2>&1; then
    selection_abs="$(realpath -- "$selection")"
    archive_abs="$(realpath -- "$(flatdir_archive_root)")"
  else
    selection_abs="$(cd -- "$selection" && pwd -P)"
    archive_abs="$(cd -- "$(flatdir_archive_root)" && pwd -P)"
  fi

  case "$selection_abs" in
    "$archive_abs"/*) rel="${selection_abs#${archive_abs}/}" ;;
    *) flatdir_die "internal error: selection not under archive_root" ;;
  esac

  [[ -n "$rel" ]] || flatdir_die "failed to compute relative path for: $selection"

  dest="$(flatdir_abs_from_home_rel "$rel")"

  if [[ -e "$dest" ]]; then
    flatdir_die "restore destination exists: $dest"
  fi

  flatdir_run_cmd mkdir -p -- "$(dirname -- "$dest")"

  flatdir_safe_mv "$selection" "$dest"
  echo "restored: $dest" >&2
}
