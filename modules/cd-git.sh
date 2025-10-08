#!/bin/zsh

cd-git() {
  local root=$(ghq root)
  local repo=$(
    ghq list | \
    while IFS= read -r r; do
      local p="$root/$r"
      local s=$(zoxide query -ls "$p" 2>/dev/null | awk '{print $1}')
      printf "%s\t%s\n" "${s:-0}" "$r"
    done | sort -rn -k1,1 | awk -F'\t' '{print $2}' | \
    fzf \
      --height 40% \
      --reverse \
      --no-sort \
      --preview 'rich --max-width 45 $(ghq root)/{}/README.md'
  )

  if [[ -n "$repo" ]]; then
    \cd "$root/$repo"
  fi
}

alias gd="cd-git"