#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew bundle --file="$DOTFILES/Brewfile"

# Symlink tracked configs into $HOME (idempotent).
link_home() {
  local rel="$1"
  local dest="${2:-$HOME/$(basename "$rel")}"
  ln -sf "$DOTFILES/$rel" "$dest"
}

link_home zsh/.zshrc
link_home emacs "$HOME/.emacs.d"
link_home vim/.vimrc
link_home tmux/.tmux.conf
