#!/bin/zsh

cd-git() {
  local root repo
  root="$(ghq root)"

  repo=$(
    ghq list | \
    while IFS= read -r r; do
      p="$root/$r"
      # zoxide `query -ls <path>` prints lines like "<score>\t<path>"
      s=$(zoxide query -ls "$p" 2>/dev/null | awk '{print $1}')
      printf "%s\t%s\n" "${s:-0}" "$r"
    done | sort -rn -k1,1 | cut -f2- | \
    fzf \
      --height 40% \
      --reverse \
      --no-sort \
      --preview "bat -p --color=always --theme=OneHalfLight --line-range :80 $root/{}/README.md"
  )

  if [[ -n "$repo" ]]; then
    \cd "$root/$repo"
  fi
}

alias gd="cd-git"
