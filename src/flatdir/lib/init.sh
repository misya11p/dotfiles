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

    # 1) Create an empty repo on GitHub
    flatdir_run_cmd gh repo create "$name" --private

    # 2) Clone into the selected managed root
    # Avoid relying on login/owner by asking gh for the repo sshUrl.
    local ssh_url
    ssh_url="$(gh repo view "$name" --json sshUrl -q .sshUrl)" || flatdir_die "failed: gh repo view"
    [[ -n "$ssh_url" ]] || flatdir_die "failed: could not determine repo sshUrl"

    flatdir_run_cmd git clone "$ssh_url" "$dest"

    # 3) Create an empty README.md and make the initial commit on main
    (
      cd -- "$dest" || flatdir_die "failed to cd: $dest"
      flatdir_run_cmd git checkout -B main
      : > README.md
      flatdir_run_cmd git add README.md
      flatdir_run_cmd git commit -m "Initial commit"
      flatdir_run_cmd git push -u origin main
    )

    echo "initialized (git): $dest" >&2
  else
    flatdir_run_cmd mkdir -p -- "$dest"
    echo "initialized: $dest" >&2
  fi
}
