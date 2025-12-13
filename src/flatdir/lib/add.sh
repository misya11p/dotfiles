#!/usr/bin/env bash
set -euo pipefail

flatdir_add() {
  local path
  path="${1:-}"

  [[ -n "$path" ]] || flatdir_die "usage: flatdir add <path>"

  if [[ ! -d "$path" ]]; then
    flatdir_die "not a directory: $path"
  fi

  # ensure managed roots are under $HOME
  local home
  home="${HOME%/}"

  # normalize to absolute path
  if command -v realpath >/dev/null 2>&1; then
    path="$(realpath -- "$path")"
  else
    # fallback: use pwd with cd
    path="$(cd -- "$path" && pwd)"
  fi

  case "$path" in
    "$home"/*) ;;
    *) flatdir_die "managed root must be under $HOME: $path" ;;
  esac

  if flatdir_is_dir_registered "$path"; then
    echo "already registered: $path" >&2
    return 0
  fi

  # load existing dirs and append
  local -a dirs=()
  local d
  while IFS= read -r d; do
    [[ -n "$d" ]] || continue
    dirs+=("$d")
  done < <(flatdir_dirs_array || true)

  dirs+=("$path")

  # validate all are dirs
  for d in "${dirs[@]}"; do
    [[ -d "$d" ]] || flatdir_die "configured dir not found: $d"
  done

  flatdir_save_dirs_array "${dirs[@]}"
  echo "added: $path" >&2
}
