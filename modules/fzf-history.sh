if command -v fzf >/dev/null 2>&1; then
    _fzf_history_from_old_file() {
        local hist_file line selected cmd ts meta epoch
        local -a lines entries

        hist_file="${HISTFILE}.bak-20260413"
        [ -f "$hist_file" ] || return

        lines=("${(@f)$(<"$hist_file")}")

        for ((i=${#lines}; i>=1; i--)); do
            line=${lines[i]}

            if [[ "$line" == ': '*':'*';'* ]]; then
                meta=${line#': '}
                epoch=${meta%%:*}
                cmd=${line#*;}

                if [[ "$epoch" == <-> ]]; then
                    ts=$(date -r "$epoch" '+%Y-%m-%d %H:%M' 2>/dev/null)
                else
                    ts='unknown'
                fi

                entries+=("${ts:-unknown}  ${cmd}"$'\t'"$cmd")
            else
                entries+=("old-entry  ${line}"$'\t'"$line")
            fi
        done

        selected=$(printf '%s\n' "${entries[@]}" | fzf --height=40% --layout=reverse --border --prompt='Old History > ' --query "$LBUFFER" --delimiter=$'\t' --with-nth=1)
        [ -z "$selected" ] && return

        print -r -- "${selected#*$'\t'}"
    }

    _fzf_history_from_current() {
        local selected event_id cmd

        selected=$(fc -l -r -i 1 | fzf --height=40% --layout=reverse --border --prompt='History > ' --query "$LBUFFER")
        [ -z "$selected" ] && return

        event_id=${${(z)selected}[1]}
        cmd=$(fc -ln "$event_id" "$event_id")
        [ -z "$cmd" ] && return

        print -r -- "$cmd"
    }

    fzf_history() {
        if [ "$1" = "--old" ]; then
            _fzf_history_from_old_file
        else
            _fzf_history_from_current
        fi
    }

    fzf_history_search() {
        local cmd
        cmd=$(fzf_history "$1")
        [ -z "$cmd" ] && return

        BUFFER="$cmd"
        CURSOR=${#BUFFER}
        zle redisplay
    }

    zle -N fzf_history_search
    bindkey '^R' fzf_history_search
fi
