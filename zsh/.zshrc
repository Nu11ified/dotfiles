export ZSH="$HOME/dotfiles/oh-my-zsh"
export ZSH_CUSTOM="$HOME/dotfiles/zsh/zsh-custom"
export PATH="$HOME/.local/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

plugins=(git)

if [ -d "$ZSH" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

if [ -f "$ZSH_CUSTOM/aliases.zsh" ]; then
  source "$ZSH_CUSTOM/aliases.zsh"
fi

if command -v brew >/dev/null 2>&1 && [ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
