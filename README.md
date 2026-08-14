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

## Project Development Tools

The Nix configuration installs a Docker-compatible container backend,
PostgreSQL 16 client tools, Google Cloud CLI, Cloud SQL Auth Proxy, and
TablePlus. PostgreSQL is not started as a Homebrew service because project
databases run in containers.

The `personal` profile uses OrbStack, which is compatible with the Docker CLI
and preserves the existing local containers and volumes. The `work` profile
installs Docker Desktop. Container data is local to each backend and is not
automatically migrated between them.

NVM is pinned by Nix and installs Node 22.23.2 as the default. Entering a
directory with an `.nvmrc` automatically installs and selects that project's
requested Node version. Corepack supplies the Yarn version pinned by the
project's `package.json`.

After the first install, launch the configured container backend once and
complete its macOS setup. Google Cloud authentication is also intentionally
per-user:

```sh
# personal profile
open -a OrbStack

# work profile
open -a Docker

gcloud init
gcloud auth application-default login
```

Verify the toolchain with:

```sh
node --version
yarn --version
docker version
pg_dump --version
psql --version
gcloud version
cloud-sql-proxy --version
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

The scripts preserve a submodule when it has uncommitted files, a checked-out
branch at another revision, or divergent local commits. They continue applying
the rest of the dotfiles and print both the local and pinned revisions instead
of overwriting in-progress work.

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

Click the power button left of the clock in SketchyBar to release or restore
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
