export ZSH="$HOME/dotfiles/oh-my-zsh"
export ZSH_CUSTOM="$HOME/dotfiles/zsh-custom"

ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh
source "$ZSH_CUSTOM/aliases.zsh"