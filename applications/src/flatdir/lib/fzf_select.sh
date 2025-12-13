#!/usr/bin/env bash
set -euo pipefail

flatdir_fzf_select() {
  flatdir_require_cmd fzf
  flatdir_require_cmd zoxide

  # collect depth1 dirs under all managed roots (full paths)
  local -a paths=()
  local root
  while IFS= read -r root; do
    [[ -n "$root" ]] || continue
    while IFS= read -r p; do
      [[ -n "$p" ]] || continue
      paths+=("$p")
    done < <(flatdir_list_depth1_dirs "$root")
  done < <(flatdir_dirs_array)

  if [[ ${#paths[@]} -eq 0 ]]; then
    flatdir_die "no directories found (did you run: flatdir add <path> ?)"
  fi

  # sort by zoxide score (keep full path for scoring)
  local sorted
  sorted="$(printf '%s\n' "${paths[@]}" | flatdir_sort_by_zoxide)"

  # build fzf rows: "display\tfullpath"
  # - display: relative path for UI (rule depends on number of managed roots)
  # - fullpath: used for preview + stdout
  local rows
  rows="$(
    while IFS= read -r p; do
      [[ -n "$p" ]] || continue
      printf '%s\t%s\n' "$(flatdir_display_path_for_dir "$p")" "$p"
    done <<<"$sorted"
  )"

  local selection_line
  selection_line="$(
    printf '%s\n' "$rows" |
      fzf \
        --height=40% \
        --reverse \
        --delimiter=$'\t' \
        --with-nth=1 \
        --preview="bash -lc 'source \"$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh\"; flatdir_preview_exec_for_path \"\$1\"' _ {2}"
  )" || true

  # align with wrapper usage: on cancel, print nothing and return success.
  if [[ -z "$selection_line" ]]; then
    return 0
  fi

  # stdout must be full path (2nd field)
  printf '%s\n' "$selection_line" | cut -f2-
}
