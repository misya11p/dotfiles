#!/bin/zsh

ghq-get() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: gg [username/repo | repo] [options...]"
    return 1
  fi

  local target="$1"
  shift

  local repo_uri
  if [[ "$target" == */* ]]; then
    repo_uri="$target"
  else
    repo_uri="git@github.com:misya11p/${target}.git"
  fi

  ghq get "$repo_uri" "$@"
  local repo_path
  repo_path=$(ghq list -p -e "$repo_uri")

  if [[ -n "$repo_path" ]]; then
    read -r "answer?cd to ${repo_path}? (Y/n) "
    if [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]; then
      \cd "$repo_path"
    fi
  fi
}

alias gg="ghq-get"
