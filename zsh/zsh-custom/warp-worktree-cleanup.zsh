# Warp has no tab-close hook. Track managed worktrees visited by this shell and
# queue an event-driven launchd check after the shell exits.
typeset -ga DOTFILES_WARP_WORKTREES
DOTFILES_WARP_WORKTREES=()

dotfiles_track_warp_worktree() {
  local worktree known

  worktree="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)" || return 0
  case "$worktree" in
    "$HOME/.warp/worktrees/"*) ;;
    *) return 0 ;;
  esac

  for known in "${DOTFILES_WARP_WORKTREES[@]}"; do
    [[ "$known" == "$worktree" ]] && return 0
  done
  DOTFILES_WARP_WORKTREES+=("$worktree")
}

dotfiles_schedule_warp_worktree_cleanup() {
  local helper="$HOME/.local/bin/warp-worktree-cleanup"
  local worktree

  [[ -x "$helper" ]] || return 0
  for worktree in "${DOTFILES_WARP_WORKTREES[@]}"; do
    "$helper" --enqueue "$worktree" >/dev/null 2>&1
  done
}

autoload -U add-zsh-hook
add-zsh-hook -d chpwd dotfiles_track_warp_worktree 2>/dev/null
add-zsh-hook -d zshexit dotfiles_schedule_warp_worktree_cleanup 2>/dev/null
add-zsh-hook chpwd dotfiles_track_warp_worktree
add-zsh-hook zshexit dotfiles_schedule_warp_worktree_cleanup
dotfiles_track_warp_worktree
