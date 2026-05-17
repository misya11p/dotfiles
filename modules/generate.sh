_natural_command_widget() {
  local model="openrouter/openai/gpt-5.4-mini"
  local -r input="${LBUFFER}"
  local -r curdir="${PWD}"
  local -r lsb="$(lsb_release -a 2>/dev/null)"

  zle kill-whole-line

  local -r system_prompt="You convert the user's current command-line draft into a complete shell command.

The draft may be:
- an incomplete shell command,
- a natural-language request,
- a short note,
- or a loose list of keywords.

Infer the user's most likely intent from the draft and the provided environment context.
Output exactly one complete shell command that best matches that intent.

Rules:
- Print only the command.
- Do not include explanations, comments, markdown, or code fences.
- Prefer a safe and non-destructive interpretation when the intent is ambiguous."

  local -r user_prompt="platform: $(uname)
shell: ${SHELL}
${lsb}

current dir: ${curdir}
current command: ${input}"

  local replacement
  replacement="$(
    {
      printf '%s\n\n%s' "$system_prompt" "$user_prompt"
    } | gum spin --itle "Generating..." -s points --show-output -- \
      sh -c "llm -m \"$model\" --no-stream -x | ruby -0777 -pe '\$_.strip!; gsub(/\n+/, \" && \")'"
  )"

  LBUFFER="${replacement}"
  zle redisplay
}
zle -N _natural_command_widget
bindkey '^g' _natural_command_widget

