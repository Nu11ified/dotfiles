# My Dotfiles

Deterministic macOS setup using Nix flakes, nix-darwin, Home Manager, AeroSpace,
SketchyBar, JankyBorders, zsh, and Emacs.

## First Install On A Mac

Clone the repo and run the install script:

```sh
git clone https://github.com/Nu11ified/dotfiles.git ~/dotfiles
~/dotfiles/scripts/install personal
```

For a work machine:

```sh
~/dotfiles/scripts/install work
```

The script installs Nix if needed, sources the Nix profile in the current shell,
and applies the requested nix-darwin flake profile.

The default `personal` and `work` profiles are currently for my personal macos account. For a Mac with a different account name, add a username-specific
configuration in `flake.nix` using the existing `mkDarwin` helper:

```nix
"youruser-work" = mkDarwin {
  username = "youruser";
  profile = "work";
};
```

Then install with:

```sh
DOTFILES_USER=youruser ~/dotfiles/scripts/install work
```

After the first build, these aliases are available:

```sh
dotfiles-install personal
dotfiles-install work
dots-install personal
```

## Daily Update Flow

Commit and push changes from one Mac:

```sh
cd ~/dotfiles
git add .
git commit -m "Update macOS workspace config"
git push
```

Pull and apply them on another Mac:

```sh
dotfiles-update personal
```

For work:

```sh
dotfiles-update work
```

Short aliases are also available:

```sh
dots-update personal
dots-update work
```

## Reloading Apps

`dotfiles-update` reloads AeroSpace and restarts SketchyBar automatically after
applying the Nix config. Manual reloads are only needed when you are testing a
bar/window-manager change without running a full update.

Emacs loads from `~/.config/emacs`, which Home Manager links directly to the
`emacs` Git submodule. Restart Emacs after changing `emacs/init.el`, or evaluate
the changed buffer with `M-x eval-buffer`.

The Emacs repository also works independently on a machine without Nix:

```sh
git clone https://github.com/Nu11ified/emacs.git ~/Documents/emacs
~/Documents/emacs/bootstrap.sh
```

After updating and pushing the Emacs repository, pin that revision in the
dotfiles repository:

```sh
cd ~/dotfiles/emacs
git pull --ff-only
cd ..
git add emacs
git commit -m "Update Emacs configuration"
git push
```

`dotfiles-install` and `dotfiles-update` initialize submodules at the exact
revision recorded by the parent repository.

## Keyboard Guide

Home Manager links the guide to:

```sh
~/.config/keyboard-shortcuts.md
```

Inside Emacs, open it with `C-c ?`.

## Workspace Map

| Key | Workspace | App shortcut |
| --- | --- | --- |
| `Option-1` | Zen | `Option-b` opens a new Zen window |
| `Option-2` | Terminals and Emacs | `Option-Enter` opens a new Ghostty window |
| `Option-3` | Codex and Claude | `Option-a` opens Codex |
| `Option-4` | Cursor and VS Code | `Option-c` opens Cursor |
| `Option-5` | Messages and Discord | `Option-i` opens Messages |
| `Option-6..9` | Miscellaneous | no automatic app assignment |

SketchyBar subscribes to an `aerospace_workspace_change` event triggered by
AeroSpace's `exec-on-workspace-change` callback, so the top bar shows the active
AeroSpace workspace instead of relying on macOS Spaces.

Click the power button after workspace `9` in SketchyBar to release or restore
AeroSpace window management. Workspace buttons dim while AeroSpace is disabled
and update immediately when it is enabled again.

Ghostty windows are tiled. Ghostty tabs remain disabled in `config/ghostty/config`
because macOS exposes those tabs through accessibility APIs as separate windows.
Use `Option-Enter` for another tiled Ghostty window, `Option-Tab` to cycle
windows, and `Option-Shift-h/j/k/l` to reorder them.

## Layout

- `flake.nix`: pinned inputs and host outputs.
- `nix/darwin.nix`: macOS defaults, packages, Homebrew apps, fonts.
- `nix/home.nix`: user dotfiles, shell, Git, Emacs, app configs.
- `config/aerospace/aerospace.toml`: tiling/window/workspace shortcuts.
- `config/aerospace/scripts/open-workspace`: launch apps into named workspaces.
- `config/sketchybar/sketchybarrc`: dark top bar.
- `config/sketchybar/plugins/aerospace.sh`: workspace status for SketchyBar.
- `config/borders/bordersrc`: focused-window borders.
- `emacs/`: pinned submodule for the standalone Emacs configuration.
