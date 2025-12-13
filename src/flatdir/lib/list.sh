#!/usr/bin/env bash
set -euo pipefail

flatdir_list() {
  flatdir_load_config

  if [[ -z "${DIRS}" ]]; then
    echo "(empty)" >&2
    return 0
  fi

  flatdir_dirs_array
}
