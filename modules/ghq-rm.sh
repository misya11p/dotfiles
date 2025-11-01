#!/bin/zsh

ghq-rm() {

  local repo=$(
    ghq list |
    fzf \
      --height 40% \
      --reverse \
      --no-sort \
      --bind 'change:reload(ghq list --full-path {q})' \
      --preview 'bat -p --color=always --theme=OneHalfLight --line-range :80 $(ghq root)/{}/README.*'
  )

  if [[ -n "$repo" ]]; then
    trash "$repo"
    echo "Removed $repo"
  fi
}

alias gr='ghq-rm'
