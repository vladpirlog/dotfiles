prompt_segment_separator="\ue0bc" # full slash
prompt_segment_separator_pair="\ue0ba" # full slash pair

prompt_branch="\ue725"
prompt_detached="\uf417"
prompt_github="\uf09b"
prompt_gitlab="\uf296"
prompt_bitbucket="\uf5a7"
prompt_gear="\uf013"
prompt_clock_01="\ue382"
prompt_clock_02="\ue383"
prompt_clock_03="\ue384"
prompt_clock_04="\ue385"
prompt_clock_05="\ue386"
prompt_clock_06="\ue387"
prompt_clock_07="\ue388"
prompt_clock_08="\ue389"
prompt_clock_09="\ue38a"
prompt_clock_10="\ue38b"
prompt_clock_11="\ue38c"
prompt_clock_12="\ue381"
prompt_exclamation_circle="\uf06a"
prompt_python="\ue606"
prompt_node="\uf898"

prompt_venv_enabled=true
prompt_venv_bg="yellow"
prompt_venv_fg="black"

prompt_git_enabled=true
prompt_git_bg="cyan"
prompt_git_fg="black"

prompt_jobs_enabled=true
prompt_jobs_bg="green"
prompt_jobs_fg="black"

prompt_retval_enabled=true
prompt_retval_error_message_enabled=false
prompt_retval_bg="red"
prompt_retval_fg="black"

prompt_time_enabled=true
prompt_time_bg="white"
prompt_time_fg="black"

prompt_segment() {
    local bg="%K{$1}"
    local fg="%F{$2}"

    if [[ -n "$3" ]]; then
        if [[ $prompt_current_bg = "NONE" ]]; then
            print -n "%F{$1}$prompt_segment_separator_pair$bg$fg $3 "
        else
            print -n "$bg%F{$prompt_current_bg}$prompt_segment_separator$fg $3 "
        fi
    fi

    prompt_current_bg="$1"
}

prompt_venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local text="$(basename $VIRTUAL_ENV)"

        [[ -n "$(find $VIRTUAL_ENV -name python)" ]] && text="$prompt_python $text"

        prompt_segment $prompt_venv_bg $prompt_venv_fg "$text"
    fi

    if [[ -n "$NODE_VIRTUAL_ENV" ]]; then
        local text="$(basename $NODE_VIRTUAL_ENV)"

        [[ -n "$(find $NODE_VIRTUAL_ENV -name node)" ]] && text="$prompt_node $text"

        prompt_segment $prompt_venv_bg $prompt_venv_fg "$text"
    fi
}

prompt_git() {
    local text="$vcs_info_msg_0_"

    if [[ -n "$text" ]]; then
        if [[ "${text/.../}" = "$text" ]]; then
            text="$prompt_branch $text"
        else
            text="$prompt_detached ${text/.../}"
        fi

        local urls=$(for r in $(git remote); do git remote get-url --all $r; done)

        [[ -n "$(echo $urls | grep bitbucket)" ]] && text="$prompt_bitbucket $text"
        [[ -n "$(echo $urls | grep gitlab)" ]] && text="$prompt_gitlab $text"
        [[ -n "$(echo $urls | grep github)" ]] && text="$prompt_github $text"

        prompt_segment $prompt_git_bg $prompt_git_fg "$text"
    fi
}

prompt_jobs() {
    local running=$(jobs -rp | wc -l)
    local stopped=$(jobs -sp | wc -l)
    local total=$(( $running + $stopped ))
    (( $total > 0 )) && prompt_segment $prompt_jobs_bg $prompt_jobs_fg "$prompt_gear $total"
}

prompt_retval() {
    if [[ $prompt_current_retval -ne 0 ]]; then
        if $prompt_retval_error_message_enabled; then
            local get_error_message_path="$HOME/.zsh/get_error_message"
            if [[ -x "$get_error_message_path" ]]; then
                local err_message="$($get_error_message_path $prompt_current_retval)"
                if [[ -n "$err_message" ]]; then
                    prompt_segment $prompt_retval_bg $prompt_retval_fg "$prompt_exclamation_circle $err_message"
                    return
                fi
            fi
        fi
        prompt_segment $prompt_retval_bg $prompt_retval_fg "$prompt_exclamation_circle $prompt_current_retval"
    fi
}

prompt_time_get_clock() {
    case "$(echo $1 | cut -f1 -d:)" in
    01) print -n $prompt_clock_01 ;;
    02) print -n $prompt_clock_02 ;;
    03) print -n $prompt_clock_03 ;;
    04) print -n $prompt_clock_04 ;;
    05) print -n $prompt_clock_05 ;;
    06) print -n $prompt_clock_06 ;;
    07) print -n $prompt_clock_07 ;;
    08) print -n $prompt_clock_08 ;;
    09) print -n $prompt_clock_09 ;;
    10) print -n $prompt_clock_10 ;;
    11) print -n $prompt_clock_11 ;;
    12) print -n $prompt_clock_12 ;;
    esac
}

prompt_time() {
    local time="$(date +%I:%M%P)"
    local clock="$(prompt_time_get_clock $time)"
    prompt_segment $prompt_time_bg $prompt_time_fg "$clock $time"
}

prompt_end() {
    print -n "%k%F{$prompt_current_bg}$prompt_segment_separator%f"
}

prompt_setup_lprompt() {
    print -n "%B%F{green}%(4~|...|)%3~ %F{red}%# %f%b"
}

prompt_setup_rprompt() {
    [ $prompt_venv_enabled ] && prompt_venv
    [ $prompt_git_enabled ] && prompt_git
    [ $prompt_jobs_enabled ] && prompt_jobs
    [ $prompt_retval_enabled ] && prompt_retval
    [ $prompt_time_enabled ] && prompt_time
    prompt_end
}

prompt_precmd() {
    prompt_current_retval=$?
    prompt_current_bg="NONE"

    vcs_info

    PROMPT="$(prompt_setup_lprompt)"
    RPROMPT="$(prompt_setup_rprompt)"
}

prompt_setup() {
    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info

    prompt_opts=(cr subst percent)

    add-zsh-hook precmd prompt_precmd

    zstyle ':vcs_info:git*' formats '%b'
    zstyle ':vcs_info:git*' actionformats '%b (%a)'
}

prompt_setup "$@"
