#!/usr/bin/env bash
set -euo pipefail

# entrypoint: subcommand dispatch only

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

cmd="${1:-}" || true

case "$cmd" in
  -a)
    shift
    # shellcheck source=lib/archive.sh
    source "${SCRIPT_DIR}/lib/archive.sh"
    flatdir_archive_select "$@"
    ;;
  "")
    # no subcommand: interactive select (prints selected path)
    # shellcheck source=lib/fzf_select.sh
    source "${SCRIPT_DIR}/lib/fzf_select.sh"
    flatdir_fzf_select
    ;;
  track)
    shift
    # shellcheck source=lib/track.sh
    source "${SCRIPT_DIR}/lib/track.sh"
    flatdir_track "$@"
    ;;
  untrack)
    shift
    # shellcheck source=lib/untrack.sh
    source "${SCRIPT_DIR}/lib/untrack.sh"
    flatdir_untrack "$@"
    ;;
  list)
    shift
    # shellcheck source=lib/list.sh
    source "${SCRIPT_DIR}/lib/list.sh"
    flatdir_list "$@"
    ;;
  remove)
    shift
    # shellcheck source=lib/remove.sh
    source "${SCRIPT_DIR}/lib/remove.sh"
    flatdir_remove "$@"
    ;;
  archive)
    shift
    # shellcheck source=lib/archive.sh
    source "${SCRIPT_DIR}/lib/archive.sh"
    flatdir_archive "$@"
    ;;
  restore)
    shift
    # shellcheck source=lib/restore.sh
    source "${SCRIPT_DIR}/lib/restore.sh"
    flatdir_restore "$@"
    ;;
  init)
    shift
    # shellcheck source=lib/init.sh
    source "${SCRIPT_DIR}/lib/init.sh"
    flatdir_init "$@"
    ;;
  clone)
    shift
    # shellcheck source=lib/clone.sh
    source "${SCRIPT_DIR}/lib/clone.sh"
    flatdir_clone "$@"
    ;;
  -h|--help|help)
    flatdir_usage
    ;;
  *)
    die "unknown subcommand: ${cmd} (use --help)"
    ;;
esac
