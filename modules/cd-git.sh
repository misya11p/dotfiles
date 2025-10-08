#!/bin/zsh

cd-git() {
  local repo=$(
    ghq list |
    while read -r line; do
      local full_path="$(ghq root)/$line"
      local score=$(zoxide query -l "$full_path" 2>/dev/null | head -n1 | awk '{print $1}')
      echo "${score:-0} $line"
    done |
    sort -rn |
    cut -d' ' -f2- |
    fzf \
      --height 40% \
      --reverse \
      --bind 'change:reload(ghq list {q})' \
      --preview 'bat -p --color=always --theme=OneHalfLight --line-range :80 $(ghq root)/{}/README.md'
  )

  if [[ -n "$repo" ]]; then
    \cd "$(ghq root)/$repo"
  fi
}

alias gd="cd-git"
