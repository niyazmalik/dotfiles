[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias gg='xclip -selection clipboard'
alias cls='clear'
alias ..='cd ..'
alias nn='nvim'


alias bv='nvim ~/.bashrc'
alias bs='source ~/.bashrc'

alias pr='cd ~/projects'

PS1='[\u@\h \W]\$ '
eval "$(starship init bash)"

export PNPM_HOME="/home/niyazmalik/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
