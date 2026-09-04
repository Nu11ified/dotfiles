alias ll="ls -lah"
alias la="ls -A"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias v="vim"
alias t="tmux"
alias clyde="export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 && export ENABLE_LSP_TOOLS=1 &&claude --dangerously-skip-permissions --model opus"
alias dotfiles-install="$HOME/dotfiles/scripts/install"
alias dotfiles-update="$HOME/dotfiles/scripts/update"
alias dots-install="dotfiles-install"
alias dots-update="dotfiles-update"
alias flake-show="nix flake show $HOME/dotfiles"
alias flake-check="nix flake check $HOME/dotfiles"
alias rsa="$HOME/dotfiles/scripts/start-desktop"
alias showsketchy="$HOME/dotfiles/scripts/start-desktop"
alias showmac='pkill -x sketchybar 2>/dev/null; pkill -x borders 2>/dev/null; defaults write NSGlobalDomain _HIHideMenuBar -bool false; killall SystemUIServer 2>/dev/null; echo "macOS menu bar restored"'
alias jankyon='pkill -x borders 2>/dev/null; borders active_color=0xffffffff inactive_color=0x00ffffff width=5.0 style=round hidpi=on >/tmp/borders.log 2>&1 &'
alias jankyoff='pkill -x borders 2>/dev/null'
alias as='cat ~/.config/keyboard-shortcuts.md'

transfer() {
  if (( $# != 3 )); then
    echo "Usage: transfer <box-id> <local-file> <devbox-destination>" >&2
    return 2
  fi

  local box_id="$1"
  local source_path="${2:A}"
  local destination="$3"

  if [[ "$box_id" != <-> ]] || (( box_id < 1 )); then
    echo "Box ID must be a positive number." >&2
    return 2
  fi

  if [[ ! -f "$source_path" ]]; then
    echo "Local file not found: $source_path" >&2
    return 1
  fi

  # zsh expands an unquoted ~/ before functions receive it. Map that local
  # home prefix back to the devbox home directory.
  if [[ "$destination" == "$HOME" ]]; then
    destination="~"
  elif [[ "$destination" == "$HOME/"* ]]; then
    destination="~/${destination#"$HOME/"}"
  fi

  command scp "$source_path" "manas@devbox-manas-${box_id}:${destination}"
}

export PATH="/opt/homebrew/opt/node@22/bin:/opt/homebrew/opt/postgresql@16/bin:$PATH"
