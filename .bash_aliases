alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias py=python3
command -v codium >/dev/null && alias code=codium
alias leetcode='cd ~/algo/leetcode && code .'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
command -v pacman >/dev/null && alias pacman='pacman --color auto'
alias startx="startx $HOME/.xinitrc"
