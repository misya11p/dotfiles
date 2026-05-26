#!/bin/bash

set -euo pipefail

DOTFILES_ROOT=$(dirname "$(dirname "$(readlink -f "$0")")")
HOME_DIR="$DOTFILES_ROOT/home"

while IFS= read -r -d '' src; do
    rel="${src#$HOME_DIR/}"
    dest="$HOME/$rel"

    if [[ -e "$dest" || -L "$dest" ]]; then
        echo "skip: $dest (already exists)"
        continue
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "linked: $dest -> $src"
done < <(find "$HOME_DIR" -type f -print0)
