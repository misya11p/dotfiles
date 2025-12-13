#!/usr/bin/env bash
set -euo pipefail

flatdir_fzf_select() {
  flatdir_require_cmd fzf
  flatdir_require_cmd zoxide

  # collect depth1 dirs under all managed roots
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

  # sort by zoxide score
  local sorted
  sorted="$(printf '%s\n' "${paths[@]}" | flatdir_sort_by_zoxide)"

  local preview
  preview=''
  # use dynamic preview command using bash -lc (fzf executes via sh by default)
  local selection
  selection="$(
    printf '%s\n' "$sorted" |
      fzf --prompt='dir> ' --height=60% --reverse \
        --preview-window='right,60%,border-left' \
        --preview='bash -lc "source \"'"$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"'\"; flatdir_preview_cmd_for_path \"{}\""'
  )" || true

  [[ -n "$selection" ]] || flatdir_die "no selection"
  echo "$selection"
}
