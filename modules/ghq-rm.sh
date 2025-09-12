#!/bin/zsh

ghq-rm() {
  set -e

  repo=$(
    ghq list |
    fzf \
      --height 40% \
      --reverse \
      --no-sort \
      --bind 'change:reload(ghq list --full-path {q})' \
      --preview 'bat -p --color=always --line-range :80 $(ghq root)/{}/README.*'
  )
  [ -z "$repo" ] && return 0

  repo_path=$(ghq root)/$repo
  rm "$repo_path"
  echo "Removed $repo_path"
}

alias gr='ghq-rm'
