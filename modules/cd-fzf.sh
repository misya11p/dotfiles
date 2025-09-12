#!/bin/zsh

cd-fzf() {
  local dir
  dir=$(
    zoxide query -l |
    sed "s|^$HOME|~|" |
    fzf \
      --height 40% \
      --reverse \
      --no-sort \
      --bind "change:reload(zoxide query -l {q} | sed 's|^$HOME|~|')" \
      --preview '
        eza \
          -lTF \
          --icons \
          --group-directories-first \
          --no-user \
          --no-permissions \
          --no-filesize \
          --time-style=long-iso \
          --color=always \
          -s=extension \
          -L=1 \
          "${HOME}$(echo {} | sed "s|^~||")"
      '
  )
  dir="${dir/#\~/$HOME}"
  z "$dir"
}

alias fd=cd-fzf
