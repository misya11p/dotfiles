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
  flatdir_run_cmd mkdir -p -- "$archive_root"

  target="$(flatdir_fzf_select)"
  [[ -n "$target" ]] || flatdir_die "no selection"
  [[ -d "$target" ]] || flatdir_die "not a directory: $target"

  # archive as if $archive_root is a virtual $HOME (store by relative path from $HOME)
  rel="$(flatdir_relpath_from_home "$target")"
  dest="${archive_root}/${rel}"

  if [[ -e "$dest" ]]; then
    flatdir_die "archive destination exists: $dest"
  fi

  flatdir_run_cmd mkdir -p -- "$(dirname -- "$dest")"

  flatdir_safe_mv "$target" "$dest"

  # marker for restore (used to list archived dirs)
  flatdir_run_cmd touch -- "$dest/.flatdir_archived"

  # cleanup candidates (do not delete by default; always confirm)
  local -a candidates=(
    ".DS_Store"
    ".venv"
    "node_modules"
    "__pycache__"
    ".ipynb_checkpoints"
  )

  local c p
  for c in "${candidates[@]}"; do
    p="${dest}/${c}"
    if [[ -e "$p" ]]; then
      if flatdir_confirm "delete '$p'?"; then
        flatdir_safe_rm "$p"
      fi
    fi
  done

  echo "archived: $dest" >&2
}

flatdir_archive_select() {
  flatdir_require_cmd fzf

  local archive_root
  archive_root="$(flatdir_archive_root)"

  [[ -d "$archive_root" ]] || flatdir_die "archive directory not found: $archive_root"

  # Use an absolute path string for bash -lc preview (avoid nested quoting issues)
  local common_sh
  common_sh="${FLATDIR_LIB_DIR}/common.sh"

  # Build fzf rows: "display\tarchive_dir"
  # - display: relative path for UI (HOME-relative)
  # - archive_dir: actual directory under archive_root (full path)
  local -a rows=()
  local marker
  while IFS= read -r marker; do
    [[ -n "$marker" ]] || continue

    local archive_dir rel display
    archive_dir="${marker%/.flatdir_archived}"
    [[ -d "$archive_dir" ]] || continue

    case "$archive_dir" in
      "$archive_root"/*) rel="${archive_dir#${archive_root}/}" ;;
      *) continue ;;
    esac

    display="$rel"
    rows+=("${display}"$'\t'"${archive_dir}")
  done < <(find "$archive_root" -type f -name '.flatdir_archived' -print 2>/dev/null || true)

  if [[ ${#rows[@]} -eq 0 ]]; then
    flatdir_die "no archived directories found"
  fi

  local selection_line
  selection_line="$(
    printf '%s\n' "${rows[@]}" |
      fzf \
        --height=60% \
        --reverse \
        --delimiter=$'\t' \
        --with-nth=1 \
        --preview="bash -lc 'source \"$common_sh\"; flatdir_preview_exec_for_path \"\$1\"' _ {2}"
  )" || true

  # align with fzf_select usage: on cancel, print nothing and return success.
  if [[ -z "$selection_line" ]]; then
    return 0
  fi

  # stdout must be full path (2nd field)
  printf '%s\n' "$selection_line" | cut -f2-
}
