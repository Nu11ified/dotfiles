export ZSH="$HOME/dotfiles/oh-my-zsh"
export ZSH_CUSTOM="$HOME/dotfiles/zsh/zsh-custom"

plugins=(git starship)

eval "$(starship init zsh)"

source $ZSH/oh-my-zsh.sh
source "$ZSH_CUSTOM/aliases.zsh"
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
