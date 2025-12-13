#!/usr/bin/env bash
set -euo pipefail

# Common helpers for flatdir

# Resolve library/root directories (used by other modules when sourcing dependencies)
FLATDIR_LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FLATDIR_ROOT_DIR="$(cd -- "${FLATDIR_LIB_DIR}/.." && pwd)"

flatdir_die() {
  echo "$1" >&2
  exit 1
}

# Backward compatible alias with README
# shellcheck disable=SC2139
alias die=flatdir_die

flatdir_run_cmd() {
  command "$@" || flatdir_die "failed: $*"
}

# Backward compatible alias with README
# shellcheck disable=SC2139
alias run_cmd=flatdir_run_cmd

flatdir_confirm() {
  local prompt ans
  prompt="$1"
  read -r -p "${prompt} [y/N] " ans
  [[ "$ans" == "y" ]]
}

# Backward compatible alias with README
# shellcheck disable=SC2139
alias confirm=flatdir_confirm

flatdir_usage() {
  cat <<'EOF'
flatdir - manage multiple directories in a single flat view

Usage:
  flatdir
  flatdir track <path>
  flatdir untrack
  flatdir list
  flatdir remove
  flatdir archive
  flatdir restore
  flatdir init <name> [--git]
  flatdir clone <git-url>
EOF
}

flatdir_require_cmd() {
  local c
  c="$1"
  command -v "$c" >/dev/null 2>&1 || flatdir_die "required command not found: $c"
}

flatdir_config_path() {
  echo "${FLATDIR_ROOT_DIR}/config"
}

flatdir_archive_root() {
  # fixed as per user answer
  echo "${HOME}/.local/share/flatdir/archive"
}

flatdir_relpath_from_home() {
  # args: absolute path under $HOME
  local abs="$1"
  local home
  home="${HOME%/}"

  case "$abs" in
    "$home"/*) echo "${abs#${home}/}" ;;
    *) flatdir_die "path is not under HOME: $abs" ;;
  esac
}

flatdir_abs_from_home_rel() {
  # args: relative path
  local rel="$1"
  [[ -n "$rel" ]] || flatdir_die "empty relpath"
  echo "${HOME%/}/${rel}"
}

flatdir_ensure_user_config_exists() {
  local cfg_dir cfg
  cfg="$(flatdir_config_path)"
  cfg_dir="$(dirname -- "$cfg")"

  if [[ ! -d "$cfg_dir" ]]; then
    flatdir_run_cmd mkdir -p "$cfg_dir"
  fi
  if [[ ! -f "$cfg" ]]; then
    cat >"$cfg" <<'EOF'
# flatdir user config
# DIRS is colon-separated list of absolute paths
# example: DIRS="$HOME/src:$HOME/work"
DIRS=""
EOF
  fi
}

flatdir_load_config() {
  flatdir_ensure_user_config_exists
  # shellcheck disable=SC1090
  source "$(flatdir_config_path)"

  : "${DIRS:=}"
}

flatdir_dirs_array() {
  # prints dirs one per line
  flatdir_load_config

  # Avoid bash array edge-cases with `set -u` by using string splitting.
  # DIRS format: "/a:/b:/c"
  local rest item
  rest="${DIRS}"

  while [[ -n "$rest" ]]; do
    if [[ "$rest" == *:* ]]; then
      item="${rest%%:*}"
      rest="${rest#*:}"
    else
      item="$rest"
      rest=""
    fi

    [[ -n "$item" ]] || continue
    echo "$item"
  done
}

flatdir_managed_roots_count() {
  local n=0
  local d
  while IFS= read -r d; do
    [[ -n "$d" ]] || continue
    n=$((n + 1))
  done < <(flatdir_dirs_array)
  echo "$n"
}

flatdir_display_path_for_dir() {
  # Convert an absolute directory path (under managed roots) to a display path for fzf.
  # Rule:
  #   - if managed roots == 1: display is root-relative (depth1 => basename)
  #   - if managed roots >= 2: display is HOME-relative
  local abs="$1"
  [[ -n "$abs" ]] || flatdir_die "empty path"

  local n root rel
  n="$(flatdir_managed_roots_count)"

  if [[ "$n" -eq 1 ]]; then
    IFS= read -r root < <(flatdir_dirs_array) || flatdir_die "no managed roots"
    case "$abs" in
      "$root"/*) rel="${abs#${root}/}" ;;
      "$root") rel="." ;;
      *) flatdir_die "path is not under managed root: $abs" ;;
    esac
    echo "$rel"
    return 0
  fi

  # 2+ roots
  echo "$(flatdir_relpath_from_home "$abs")"
}

flatdir_abs_path_from_display() {
  # Convert a display path selected in fzf back to an absolute path.
  # Rule:
  #   - if managed roots == 1: display is root-relative
  #   - if managed roots >= 2: display is HOME-relative
  local disp="$1"
  [[ -n "$disp" ]] || flatdir_die "empty display path"

  local n root
  n="$(flatdir_managed_roots_count)"

  if [[ "$n" -eq 1 ]]; then
    IFS= read -r root < <(flatdir_dirs_array) || flatdir_die "no managed roots"
    if [[ "$disp" == "." ]]; then
      echo "$root"
    else
      echo "${root%/}/${disp}"
    fi
    return 0
  fi

  # 2+ roots
  echo "$(flatdir_abs_from_home_rel "$disp")"
}

flatdir_is_dir_registered() {
  local target="$1"
  local d
  while IFS= read -r d; do
    if [[ "$d" == "$target" ]]; then
      return 0
    fi
  done < <(flatdir_dirs_array)
  return 1
}

flatdir_save_dirs_array() {
  # args: list of dirs (already validated), writes DIRS="a:b:c" to config
  local cfg tmp joined
  cfg="$(flatdir_config_path)"
  tmp="${cfg}.tmp.$$"

  joined=""
  local d
  for d in "$@"; do
    [[ -n "$d" ]] || continue
    if [[ -z "$joined" ]]; then
      joined="$d"
    else
      joined="${joined}:$d"
    fi
  done

  {
    echo "# flatdir user config"
    echo "# DIRS is colon-separated list of absolute paths"
    echo "DIRS=\"${joined}\""
  } >"$tmp"

  flatdir_run_cmd mv "$tmp" "$cfg"
}

flatdir_pick_managed_root() {
  # select one of managed roots; prints selection
  # behavior:
  #   - 0 roots: error
  #   - 1 root : return it (no fzf)
  #   - 2+    : select via fzf

  local -a roots=()
  local d
  while IFS= read -r d; do
    [[ -n "$d" ]] || continue
    roots+=("$d")
  done < <(flatdir_dirs_array)

  if [[ ${#roots[@]} -eq 0 ]]; then
    flatdir_die "no managed roots (did you run: flatdir track <path> ?)"
  fi

  if [[ ${#roots[@]} -eq 1 ]]; then
    echo "${roots[0]}"
    return 0
  fi

  flatdir_require_cmd fzf

  local selection
  selection="$(printf '%s\n' "${roots[@]}" | fzf --prompt='managed root> ' --height=40% --reverse)" || true

  [[ -n "$selection" ]] || flatdir_die "no selection"
  echo "$selection"
}

flatdir_list_depth1_dirs() {
  # args: managed_root
  local root="$1"
  [[ -d "$root" ]] || flatdir_die "not a directory: $root"

  # exclude hidden directories
  # portable-ish: use find with -maxdepth/-mindepth
  find "$root" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -print
}

flatdir_zoxide_score() {
  # args: path
  local p="$1"
  flatdir_require_cmd zoxide

  # zoxide query -ls outputs: "score path" (all entries)
  # find exact match; if not found, score=0
  local score
  score="$(zoxide query -ls 2>/dev/null | awk -v target="$p" '$2==target{print $1; exit}')" || true
  [[ -n "$score" ]] || score="0"
  echo "$score"
}

flatdir_sort_by_zoxide() {
  # reads newline-separated paths from stdin, outputs paths sorted desc by zoxide score
  local p
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    printf '%s\t%s\n' "$(flatdir_zoxide_score "$p")" "$p"
  done | sort -rn | cut -f2-
}

flatdir_preview_cmd_for_path() {
  # prints a shell snippet to preview a directory.
  # NOTE: fzf --preview expects a command to *execute*.
  # This function returns such a command string and must be executed by caller (e.g. via `eval`).
  local p="$1"
  local readme=""

  if [[ -f "${p}/README.md" ]]; then
    readme="${p}/README.md"
  elif [[ -f "${p}/README" ]]; then
    readme="${p}/README"
  fi

  if [[ -n "$readme" ]]; then
    # As requested: for now, use cat instead of rich-based conditional behavior.
    printf 'cat -- "%s" | sed -n "1,200p"' "$readme"
  else
    if command -v eza >/dev/null 2>&1; then
      printf 'eza -lTF --icons --group-directories-first --no-user --no-permissions --no-filesize --time-style=long-iso --color=always -s=extension -L=1 -- "%s"' "$p"
    else
      printf 'ls -la -- "%s"' "$p"
    fi
  fi
}

flatdir_preview_exec_for_path() {
  # exec preview for fzf. Avoids eval/quoting issues by executing directly.
  local p="$1"
  local readme=""

  if [[ -f "${p}/README.md" ]]; then
    readme="${p}/README.md"
  elif [[ -f "${p}/README" ]]; then
    readme="${p}/README"
  fi

  if [[ -n "$readme" ]]; then
    if command -v rich >/dev/null 2>&1; then
      # Follow samples/cd-git.sh: respect FZF_PREVIEW_COLUMNS for width.
      local cols
      cols="${FZF_PREVIEW_COLUMNS:-80}"
      rich --max-width "$cols" -- "$readme"
    else
      # Fallback when rich is not available.
      sed -n '1,200p' -- "$readme"
    fi
    return 0
  fi

  if command -v eza >/dev/null 2>&1; then
    eza -lTF \
      --icons \
      --group-directories-first \
      --no-user \
      --no-permissions \
      --no-filesize \
      --time-style=long-iso \
      --color=always \
      -s=extension \
      -L=1 \
      -- "$p"
  else
    ls -la -- "$p"
  fi
}

flatdir_safe_mv() {
  # args: src dst
  local src="$1" dst="$2"

  [[ -e "$src" ]] || flatdir_die "mv src not found: $src"
  if [[ -e "$dst" ]]; then
    flatdir_die "destination exists: $dst"
  fi

  flatdir_run_cmd mv -- "$src" "$dst"
}

flatdir_safe_rm() {
  # args: path
  local p="$1"
  [[ -e "$p" ]] || flatdir_die "not found: $p"
  flatdir_run_cmd trash "$p"
}
