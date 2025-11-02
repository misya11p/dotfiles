#!/bin/zsh

git-init() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: gi <reponame> [--public]"
    exit 1
  fi

  local repo=$1
  shift

  visibility="--private"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --public)
        visibility=""
        ;;
      *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
    shift
  done

  gh repo create "$repo" $visibility
  ghq get git@github.com:misya11p/${repo}.git
  repo_dir="$(ghq root)/github.com/misya11p/${repo}"
  cd "$repo_dir" || { echo "Failed to cd to $repo_dir"; exit 1; }
  git checkout -b main

  touch README.md
  git add README.md
  git commit -m "Initial commit"
  git push -u origin main

  if [[ -n "$repo_dir" ]]; then
    read -r "answer?cd to ${repo_dir}? (Y/n) "
    if [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]; then
      \cd "$repo_dir"
    fi
  fi
}

alias gi="git-init"
