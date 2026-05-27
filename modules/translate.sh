translate_cmd() {
  local -r max_bytes=10240
  local -r system_prompt='You are a professional translator. Translate documents provided by users into natural, fluent English/Japanese.

Requirements:
- When given a Japanese document, translate it into English
- When given a non-Japanese document, translate it into Japanese
- Preserve the original meaning exactly. Properly translate all elements without adding, removing, or altering any content
- Maintain the original document format (including Markdown structure, headings, lists, line breaks, code blocks, tables, etc.)
- Do not translate elements that do not need translation (such as mathematical formulas or code)
- Your output will be directly provided to the user. Do not output any text other than the translated text. Avoid including explanations, notes, or comments, and refrain from wrapping the output in code fences'
  local tmp_file input_bytes answer exit_status

  tmp_file="$(mktemp -t translate.XXXXXX)"

  if [ "$#" -gt 0 ]; then
    local file
    for file in "$@"; do
      if [ "$file" != "-" ] && [ ! -f "$file" ]; then
        printf 'translate: file not found: %s\n' "$file" >&2
        exit_status=1
        break
      fi
    done

    if [ -z "$exit_status" ]; then
      for file in "$@"; do
        if [ "$file" = "-" ]; then
          command cat
        else
          command cat -- "$file"
        fi
      done > "$tmp_file"
    fi
  elif [ -t 0 ]; then
    printf 'usage: translate FILE...\n       command | translate\n       translate < FILE\n' >&2
    exit_status=2
  else
    command cat > "$tmp_file"
  fi

  if [ -z "$exit_status" ]; then
    input_bytes="$(wc -c < "$tmp_file" | tr -d ' ')"
    if [ "$input_bytes" -gt "$max_bytes" ]; then
      printf 'translate: input is %s bytes. continue? [y/N] ' \
        "$input_bytes" >/dev/tty
      read -r answer </dev/tty

      case "$answer" in
        [yY]) ;;
        *) printf 'translate: aborted\n' >&2; exit_status=1 ;;
      esac
    fi
  fi

  if [ -z "$exit_status" ]; then
    export TRANSLATE_SYSTEM_PROMPT="$system_prompt"
    gum spin --title "Translating..." -s points --show-output -- \
      sh -c 'llm -s "$TRANSLATE_SYSTEM_PROMPT" < "$1"' sh "$tmp_file"
    exit_status="$?"
    unset TRANSLATE_SYSTEM_PROMPT
  fi

  rm -f "$tmp_file"
  return "$exit_status"
}

alias translate=translate_cmd
