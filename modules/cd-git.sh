#!/bin/zsh

cd-git() {
  local repo_path
  repo_path=$(
    ghq list |
      fzf \
        --height 60% \
        --reverse \
        --no-sort \
        --bind 'change:reload(ghq list --full-path {q})' \
        --preview 'bat -p --color=always --line-range :80 $(ghq root)/{}/README.*'
  )
  z "$repo_path"
}
alias gd="cd-git"