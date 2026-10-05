[[ $- != *i* ]] && return

export EDITOR=nvim
export PATH="$HOME/.local/bin:$PATH:$HOME/go/bin"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias nn='nvim'
alias ..='cd ..'
alias cls='clear'
alias gg='rg'
alias cpwd='pwd | tr -d "\n" | xclip -selection clipboard'
alias bv='nvim ~/.bashrc'
alias bs='source ~/.bashrc'

kk() {
    if [[ -z "$1" ]]; then
        echo "Usage: kk <port>"
        return 1
    fi

    sudo fuser -k "$1"/tcp && echo -e "\e[96mTerminated!\e[0m" || echo "No process found on port $1"
}

dev() {
    local name=$1
    local path=$2

    tmux has-session -t "$name" 2>/dev/null && tmux attach -t "$name" && return

    tmux new-session -d -s "$name" -c "$path"
    tmux attach -t "$name"
}

[[ -r /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

export OSH="$HOME/.oh-my-bash"
OSH_THEME="robbyrussell-niyaz"
DISABLE_AUTO_UPDATE="true"
completions=()
aliases=()
plugins=()
source "$OSH/oh-my-bash.sh"
unset CDPATH

[[ -r ~/.bash_local ]] && source ~/.bash_local
