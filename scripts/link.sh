#!/bin/bash

set -euo pipefail

DOTFILES_ROOT=$(dirname "$(dirname "$(readlink -f "$0")")")

: "${XDG_CONFIG_HOME:?XDG_CONFIG_HOME is not set. Source zshenv first.}"
: "${ZDOTDIR:?ZDOTDIR is not set. Source zshenv first.}"

link_files() {
    local src_dir="$1"
    local dest_dir="$2"
    local dot_prefix="${3:-false}"

    while IFS= read -r -d '' src; do
        local rel="${src#$src_dir/}"
        local dest="$dest_dir/$(basename "$rel")"

        if [[ "$dot_prefix" == true ]]; then
            dest="$dest_dir/.$(basename "$rel")"
        fi

        if [[ -e "$dest" || -L "$dest" ]]; then
            echo "skip: $dest (already exists)"
            continue
        fi

        mkdir -p "$(dirname "$dest")"
        ln -s "$src" "$dest"
        echo "linked: $dest -> $src"
    done < <(find "$src_dir" -type f -print0)
}

link_files "$DOTFILES_ROOT/config" "$XDG_CONFIG_HOME"
link_files "$DOTFILES_ROOT/zsh" "$ZDOTDIR" true
