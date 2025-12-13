flatdir() {
    local out
    out="$("$DOTFILES_ROOT/src/flatdir/entrypoint.sh" "$@")" || return

    [ -z "$out" ] && return

    if [ -d "$out" ]; then
        cd "$out"
    else
        printf '%s\n' "$out"
    fi
}

alias fd=flatdir
