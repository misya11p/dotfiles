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
  if [[ -n "$repo_id" ]]; then
    \cd "$(ghq root)/$repo_id"
  fi
}

alias gd="cd-git"
