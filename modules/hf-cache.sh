hf-cache() {
  if ! command -v hf >/dev/null 2>&1; then
    printf 'hf-cache: hf command not found\n' >&2
    return 127
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    printf 'hf-cache: fzf command not found\n' >&2
    return 127
  fi

  local listing selected line
  local -a targets

  listing="$(hf cache ls --no-revisions --format table)" || return

  case "$listing" in
    'No cached repositories found.')
      printf '%s\n' "$listing"
      return
      ;;
  esac

  selected="$(
    printf '%s\n' "$listing" |
      sed '/^$/,$d' |
      fzf --multi \
        --header-lines=2 \
        --prompt='HF cache> ' \
        --header='Tab: select  Enter: remove' \
        --bind='ctrl-a:select-all,ctrl-d:deselect-all'
  )" || return 0

  [ -z "$selected" ] && return

  for line in "${(@f)selected}"; do
    targets+=("${line%%[[:space:]]*}")
  done

  hf cache rm "${targets[@]}"
}
