alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias poweroff='sudo systemctl poweroff -i'
alias vim='nvim'
alias tree='tree -aC -I .git'

PS1="\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ "

source /etc/profile.d/vte.sh
source $HOME/.profile

set -o vi
