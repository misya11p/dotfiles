#!/usr/bin/env bash
set -euo pipefail

flatdir_untrack() {
  # usage: flatdir untrack
  if [[ $# -ne 0 ]]; then
    flatdir_die "usage: flatdir untrack"
  fi

  flatdir_require_cmd fzf

  # list managed roots
  local -a roots=()
  local d
  while IFS= read -r d; do
    [[ -n "$d" ]] || continue
    roots+=("$d")
  done < <(flatdir_dirs_array)

  if [[ ${#roots[@]} -eq 0 ]]; then
    flatdir_die "no managed roots"
  fi

  local target
  target="$(printf '%s\n' "${roots[@]}" | fzf --prompt='untrack> ' --height=40% --reverse)" || true

  [[ -n "$target" ]] || flatdir_die "no selection"

  # rebuild list without target
  local -a kept=()
  for d in "${roots[@]}"; do
    if [[ "$d" != "$target" ]]; then
      kept+=("$d")
    fi
  done

  flatdir_save_dirs_array "${kept[@]}"
  echo "untracked: $target" >&2
}
