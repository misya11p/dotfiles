#!/usr/bin/env bash
set -euo pipefail

flatdir_init() {
  local name use_git
  name="${1:-}"
  use_git="${2:-}"

  [[ -n "$name" ]] || flatdir_die "usage: flatdir init <name> [--git]"

  local root dest rel archive_conflict
  root="$(flatdir_pick_managed_root)"
  dest="${root}/${name}"

  if [[ -e "$dest" ]]; then
    flatdir_die "already exists: $dest"
  fi

  # prevent collision with archived path (archive keeps HOME-relative structure)
  rel="$(flatdir_relpath_from_home "$dest")"
  archive_conflict="$(flatdir_archive_root)/${rel}"
  if [[ -e "$archive_conflict" ]]; then
    flatdir_die "cannot init: archived path exists: $archive_conflict"
  fi

  if [[ "$use_git" == "--git" ]]; then
    flatdir_require_cmd gh
    flatdir_require_cmd git

    # create repo on GitHub and clone into dest
    # NOTE: gh repo create accepts --clone and --add-readme etc. We'll keep it minimal.
    # We create repo with the given name (in current user namespace) and clone.
    # To control clone destination, we use --clone then move, or use git clone afterwards.

    # create without prompting
    flatdir_run_cmd gh repo create "$name" --private --confirm

    # clone into chosen managed root
    flatdir_run_cmd git clone "git@github.com:$(gh api user -q .login)/${name}.git" "$dest"
    echo "initialized (git): $dest" >&2
  else
    flatdir_run_cmd mkdir -p -- "$dest"
    echo "initialized: $dest" >&2
  fi
}
