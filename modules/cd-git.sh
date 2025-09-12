#!/bin/zsh

cd-git() {
  local repo=$(
    ghq list |
    fzf \
      --height 40% \
      --reverse \
      --no-sort \
      --bind 'change:reload(ghq list {q})' \
      --preview 'bat -p --color=always --theme=OneHalfLight --line-range :80 $(ghq root)/{}/README.md'
  )

  if [[ -n "$repo" ]]; then
    \cd "$(ghq root)/$repo"
  fi
}

alias gd="cd-git"
