#!/bin/zsh

cd-git() {
  local repo_path
  repo_id=$(
    ghq list |
    fzf \
      --height 40% \
      --reverse \
      --no-sort \
      --bind 'change:reload(ghq list {q})' \
      --preview 'bat -p --color=always --line-range :80 $(ghq root)/{}/README.md'
  )
  \cd "$(ghq root)/$repo_id"
}

alias gd="cd-git"
