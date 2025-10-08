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
    sed 's|^github\.com/||' | \
    fzf \
      --height 65% \
      --reverse \
      --no-sort \
      --preview 'rich --max-width 45 $(ghq root)/github.com/{}/README.md'
  )

  if [[ -n "$repo" ]]; then
    \cd "$root/github.com/$repo"
  fi
}

alias gd="cd-git"