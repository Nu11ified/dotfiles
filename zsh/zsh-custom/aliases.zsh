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
alias rsa="$HOME/dotfiles/scripts/start-desktop"
alias showsketchy="$HOME/dotfiles/scripts/start-desktop"
alias showmac='pkill -x sketchybar 2>/dev/null; pkill -x borders 2>/dev/null; defaults write NSGlobalDomain _HIHideMenuBar -bool false; killall SystemUIServer 2>/dev/null; echo "macOS menu bar restored"'
alias jankyon='pkill -x borders 2>/dev/null; borders active_color=0xffffffff inactive_color=0x00ffffff width=5.0 style=round hidpi=on >/tmp/borders.log 2>&1 &'
alias jankyoff='pkill -x borders 2>/dev/null'
alias as='cat ~/.config/keyboard-shortcuts.md'
