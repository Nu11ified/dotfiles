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

Emacs loads from `~/.emacs.d`, managed by Home Manager. Restart Emacs after
changing `emacs/init.el`, or evaluate the changed buffer with `M-x eval-buffer`.

## Keyboard Guide

Home Manager links the guide to:

```sh
~/.config/keyboard-shortcuts.md
```

Inside Emacs, open it with `C-c ?`.

## Workspace Map

| Key | Workspace | App shortcut |
| --- | --- | --- |
| `Option-1` | `W` web | `Option-b` opens Google Chrome |
| `Option-2` | `T` terminal | `Option-Enter` opens Ghostty |
| `Option-3` | `S` ssh | `Option-s` opens Termius |
| `Option-4` | `E` emacs | `Option-e` opens Emacs |
| `Option-5` | `M` music | `Option-m` opens Music |
| `Option-6` | `A` agents | `Option-a` opens Codex |
| `Option-7` | `C` code | `Option-c` opens Cursor |
| `Option-8` | `N` notes | manual workspace |
| `Option-9` | `G` git/factory | automatic GitForge/Factory matching |

SketchyBar subscribes to an `aerospace_workspace_change` event triggered by
AeroSpace's `exec-on-workspace-change` callback, so the top bar shows the active
AeroSpace workspace instead of relying on macOS Spaces.

## Layout

- `flake.nix`: pinned inputs and host outputs.
- `nix/darwin.nix`: macOS defaults, packages, Homebrew apps, fonts.
- `nix/home.nix`: user dotfiles, shell, Git, Emacs, app configs.
- `config/aerospace/aerospace.toml`: tiling/window/workspace shortcuts.
- `config/aerospace/scripts/open-workspace`: launch apps into named workspaces.
- `config/sketchybar/sketchybarrc`: dark top bar.
- `config/sketchybar/plugins/aerospace.sh`: workspace status for SketchyBar.
- `config/borders/bordersrc`: focused-window borders.
- `emacs/init.el`: default-keybinding editor and Org notes setup.
