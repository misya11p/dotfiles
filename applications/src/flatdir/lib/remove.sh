#!/usr/bin/env bash
set -euo pipefail

# dependencies
# shellcheck source=lib/fzf_select.sh
source "${FLATDIR_LIB_DIR}/fzf_select.sh"

flatdir_remove() {
  # select a directory from managed roots (depth 1) then delete it
  local target

  target="$(flatdir_fzf_select)"

  [[ -n "$target" ]] || flatdir_die "no selection"
  [[ -d "$target" ]] || flatdir_die "not a directory: $target"

  flatdir_safe_rm_rf "$target"
}
