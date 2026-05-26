#!/bin/bash

set -euo pipefail

DOTFILES_ROOT=$(dirname "$(dirname "$(readlink -f "$0")")")
HOME_DIR="$DOTFILES_ROOT/home"
HOME_DIR_ABS=$(cd "$HOME_DIR" && pwd -P)

while IFS= read -r -d '' src; do
    rel="${src#$HOME_DIR/}"
    dest="$HOME/$rel"
    action="linked"

    if [[ -e "$dest" || -L "$dest" ]]; then
        overwrite=false

        if [[ -L "$dest" ]]; then
            target=$(readlink "$dest")
            [[ "$target" != /* ]] && target="$(dirname "$dest")/$target"

            if [[ -e "$target" ]]; then
                target_abs=$(cd "$(dirname "$target")" && pwd -P)/$(basename "$target")
            else
                target_abs="$target"
            fi

            if [[ "$target_abs" == "$HOME_DIR_ABS"/* ]]; then
                overwrite=true
                action="relinked"
            fi
        fi

        if [[ "$overwrite" != true ]]; then
            answer=
            if [[ -r /dev/tty && -w /dev/tty ]]; then
                printf "overwrite: %s? [y/N] " "$dest" >/dev/tty
                read -r answer </dev/tty || true
            fi

            case "$answer" in
                [yY])
                    overwrite=true
                    action="overwritten"
                    ;;
                *)
                    echo "skip: $dest (already exists)"
                    continue
                    ;;
            esac
        fi

        trash "$dest"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "$action: $dest -> $src"
done < <(find "$HOME_DIR" -type f -print0)
