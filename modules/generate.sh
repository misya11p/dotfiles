_natural_command_widget() {
  local model="openrouter/x-ai/grok-4.20"
  local -r input="${LBUFFER}"

  zle kill-whole-line

  local lsb=$(lsb_release -a 2>/dev/null)
  local prompt="Write a complete shell command based on the given the one-liner draft with the instruction.
Only print the resulting command.
platform: $(uname)
shell: $(echo $SHELL)
${lsb}

current dir: ${curdir}
current command: ${input}"

  local replacement=$(echo $prompt | gum spin --title "Generating..." -s points --show-output -- sh -c "llm -m $model --no-stream -x | ruby -0777 -pe '\$_.strip!; gsub(/\n+/, \" && \")'")

  # echo -n $replacement
  LBUFFER="${replacement}"
  zle redisplay
}
zle -N _natural_command_widget
bindkey '^g' _natural_command_widget
