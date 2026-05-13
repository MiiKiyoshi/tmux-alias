#!/usr/bin/env bash
# tmux_alias completion (bash + zsh via bashcompinit)
#
# Bash — add to ~/.bashrc:
#     source /path/to/tmux_alias/completion/tmux_alias.bash
#
# Zsh — add to ~/.zshrc:
#     autoload -Uz bashcompinit && bashcompinit
#     source /path/to/tmux_alias/completion/tmux_alias.bash
#
# Completes:
#   <session>                  — session names
#   <session>:<window>         — window index or name
#   <session>:<window>.<pane>  — pane index

_tmux_alias_target() {
    local full sess rest win panes wins sessions
    local IFS=$'\n'

    # Extract full token under cursor, ignoring COMP_WORDBREAKS (which splits on `:`).
    full="${COMP_LINE:0:$COMP_POINT}"
    full="${full##* }"

    if [[ $full == *:* ]]; then
        sess="${full%%:*}"
        rest="${full#*:}"
        if [[ $rest == *.* ]]; then
            win="${rest%.*}"
            panes=$(tmux list-panes -t "=$sess:$win" -F "$win"'.#{pane_index}' 2>/dev/null)
            COMPREPLY=($(compgen -W "$panes" -- "$rest"))
        else
            wins=$(tmux list-windows -t "=$sess" -F '#{window_index}'$'\n''#{window_name}' 2>/dev/null)
            COMPREPLY=($(compgen -W "$wins" -- "$rest"))
        fi
    else
        sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
        COMPREPLY=($(compgen -W "$sessions" -- "$full"))
    fi
}

_tmux_alias_with_flags() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [[ $cur == -* ]]; then
        COMPREPLY=($(compgen -W "$1" -- "$cur"))
        return
    fi
    _tmux_alias_target
}

_cdt_complete() { _tmux_alias_target; }
_rmt_complete() { _tmux_alias_target; }
_mkt_complete() { _tmux_alias_with_flags "-p -v -h"; }
_mvt_complete() { _tmux_alias_with_flags "-v -h"; }

_stt_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local sessions
    local IFS=$'\n'
    if [[ $cur == -* ]]; then
        COMPREPLY=($(compgen -W "-v -w" -- "$cur"))
        return
    fi
    sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
    COMPREPLY=($(compgen -W "$sessions" -- "$cur"))
}

complete -F _cdt_complete cdt
complete -F _mkt_complete mkt
complete -F _mvt_complete mvt
complete -F _rmt_complete rmt
complete -F _stt_complete stt
