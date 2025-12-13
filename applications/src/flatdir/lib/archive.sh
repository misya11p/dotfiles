#!/usr/bin/env bash
set -euo pipefail

# dependencies
# shellcheck source=lib/fzf_select.sh
source "${FLATDIR_LIB_DIR}/fzf_select.sh"

flatdir_archive() {
  flatdir_require_cmd mkdir
  flatdir_require_cmd mv

  local target archive_root rel dest

  archive_root="$(flatdir_archive_root)"
  run_cmd mkdir -p -- "$archive_root"

  target="$(flatdir_fzf_select)"
  [[ -n "$target" ]] || flatdir_die "no selection"
  [[ -d "$target" ]] || flatdir_die "not a directory: $target"

  # archive as if $archive_root is a virtual $HOME (store by relative path from $HOME)
  rel="$(flatdir_relpath_from_home "$target")"
  dest="${archive_root}/${rel}"

  if [[ -e "$dest" ]]; then
    flatdir_die "archive destination exists: $dest"
  fi

  run_cmd mkdir -p -- "$(dirname -- "$dest")"

  flatdir_safe_mv "$target" "$dest"

  # marker for restore (used to list archived dirs)
  run_cmd touch -- "$dest/.flatdir_archived"

  # cleanup candidates (do not delete by default; always confirm)
  local -a candidates=(
    ".venv"
    "node_modules"
    "__pycache__"
    "etc"
  )

  local c p
  for c in "${candidates[@]}"; do
    p="${dest}/${c}"
    if [[ -e "$p" ]]; then
      if flatdir_confirm "delete '$p'?"; then
        flatdir_run_cmd rm -rf -- "$p"
      fi
    fi
  done

  echo "archived: $dest" >&2
}
