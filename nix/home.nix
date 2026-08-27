{ pkgs, lib, config, username, profile, ... }:

let
  nodeDefaultVersion = "22.23.2";
  nvmSource = pkgs.fetchFromGitHub {
    owner = "nvm-sh";
    repo = "nvm";
    rev = "v0.40.6";
    hash = "sha256-60diMTawrIlyB29GrYcRuv5RBawGxpW82FHYWmHQgbg=";
  };
in

{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # Core build tooling
    cmake
    libtool

    # Nix
    nil
    nixpkgs-fmt

    # Rust
    cargo
    clippy
    rust-analyzer
    rustc
    rustfmt

    # Zig
    zig
    zls

    # Lua
    lua5_4
    lua-language-server
    luarocks
    stylua

    # Clojure and JVM
    babashka
    clojure
    clojure-lsp
    jdk
    leiningen

    # JavaScript and TypeScript
    bun
    deno
    typescript
    typescript-language-server

    # Python
    pyright
    python313
    ruff
    uv

    # Go
    go
    gopls

    # Editor acceleration
    emacs-lsp-booster
  ];

  programs.home-manager.enable = true;

  home.sessionVariables.PNPM_HOME = "${config.home.homeDirectory}/Library/pnpm";

  home.sessionPath = [
    "${config.home.homeDirectory}/Library/pnpm"
    "${config.home.homeDirectory}/Library/pnpm/bin"
    "/opt/homebrew/opt/postgresql@16/bin"
    "/opt/homebrew/share/google-cloud-sdk/bin"
  ];

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    shellAliases = {
      ll = "eza -lah --git";
      cat = "bat";
      rebuild = "darwin-rebuild switch --flake ~/dotfiles#personal";
      rebuild-work = "darwin-rebuild switch --flake ~/dotfiles#work";
      rebuild-remote = "darwin-rebuild switch --flake github:Nu11ified/dotfiles#personal";
      rebuild-work-remote = "darwin-rebuild switch --flake github:Nu11ified/dotfiles#work";
      dots = "cd ~/dotfiles";
      dotfiles-install = "~/dotfiles/scripts/install";
      dotfiles-update = "~/dotfiles/scripts/update";
      dots-install = "~/dotfiles/scripts/install";
      dots-update = "~/dotfiles/scripts/update";
      rebuild-current = "darwin-rebuild switch --flake ~/dotfiles#${username}-${profile}";
      flake-show = "nix flake show ~/dotfiles";
      flake-check = "nix flake check ~/dotfiles";
    };
    initContent = ''
      if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi

      if [ -e /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh ]; then
        source /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh
      fi

      export ZSH="$HOME/dotfiles/oh-my-zsh"
      export ZSH_CUSTOM="$HOME/dotfiles/zsh/zsh-custom"
      export PATH="$HOME/.local/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"
      export NVM_DIR="$HOME/.nvm"
      unset NPM_CONFIG_PREFIX npm_config_prefix

      if [ -r "$HOME/.config/zsh/secrets.zsh" ]; then
        source "$HOME/.config/zsh/secrets.zsh"
      fi

      source "${nvmSource}/nvm.sh"

      autoload -U add-zsh-hook
      load-nvmrc() {
        local nvmrc_path="$(nvm_find_nvmrc)"

        if [ -n "$nvmrc_path" ]; then
          local requested_version="$(nvm version "$(cat "$nvmrc_path")")"
          if [ "$requested_version" = "N/A" ]; then
            nvm install
            corepack enable
          elif [ "$requested_version" != "$(nvm version)" ]; then
            nvm use
          fi
        elif [ "$(nvm version)" != "$(nvm version default)" ]; then
          nvm use default
        fi
      }
      add-zsh-hook chpwd load-nvmrc
      load-nvmrc

      if [ -d "$ZSH" ]; then
        plugins=(git)
        source "$ZSH/oh-my-zsh.sh"
      fi

      if [ -f "$ZSH_CUSTOM/aliases.zsh" ]; then
        source "$ZSH_CUSTOM/aliases.zsh"
      fi

      if command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
      fi
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.activation.ensurePrivateZshSecrets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    secrets_dir="$HOME/.config/zsh"
    secrets_file="$secrets_dir/secrets.zsh"

    /bin/mkdir -p "$secrets_dir"
    /bin/chmod 700 "$secrets_dir"
    if [ ! -e "$secrets_file" ]; then
      /usr/bin/install -m 600 /dev/null "$secrets_file"
    fi
    /bin/chmod 600 "$secrets_file"
  '';

  home.activation.installNodeToolchain = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"
    export NVM_DIR="$HOME/.nvm"
    unset NPM_CONFIG_PREFIX npm_config_prefix
    mkdir -p "$NVM_DIR"
    source "${nvmSource}/nvm.sh"

    nvm install "${nodeDefaultVersion}"
    nvm alias default "${nodeDefaultVersion}"
    nvm use --silent default
    corepack enable
  '';

  home.activation.installOpenAICodexCli = lib.hm.dag.entryAfter [ "installNodeToolchain" ] ''
    export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"
    export NVM_DIR="$HOME/.nvm"
    unset NPM_CONFIG_PREFIX npm_config_prefix
    source "${nvmSource}/nvm.sh"
    nvm use --silent default

    if ! command -v codex >/dev/null 2>&1; then
      npm install -g @openai/codex
    fi
  '';

  home.activation.migrateLegacyEmacsConfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    backup_legacy_emacs_path() {
      local legacy_path="$1"
      local backup_path="$legacy_path.pre-xdg"

      if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
        backup_path="$backup_path.$(date +%Y%m%d%H%M%S)"
      fi

      mv "$legacy_path" "$backup_path"
      echo "Moved legacy Emacs path to $backup_path"
    }

    if [ -e "$HOME/.emacs" ] || [ -L "$HOME/.emacs" ]; then
      backup_legacy_emacs_path "$HOME/.emacs"
    fi
    if [ -e "$HOME/.emacs.el" ] || [ -L "$HOME/.emacs.el" ]; then
      backup_legacy_emacs_path "$HOME/.emacs.el"
    fi
    if [ -e "$HOME/.emacs.d/init.el" ] || [ -L "$HOME/.emacs.d/init.el" ]; then
      backup_legacy_emacs_path "$HOME/.emacs.d"
    fi
  '';

  home.file.".config/emacs" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/emacs";
    force = true;
  };
  home.file.".config/aerospace/aerospace.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/config/aerospace/aerospace.toml";
    force = true;
  };
  home.file.".config/aerospace/scripts/open-app" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/config/aerospace/scripts/open-app";
    force = true;
  };
  home.file.".config/aerospace/scripts/arrange-monitors" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/config/aerospace/scripts/arrange-monitors";
    force = true;
  };
  home.file.".config/sketchybar/sketchybarrc" = {
    source = ../config/sketchybar/sketchybarrc;
    executable = true;
  };
  home.file.".config/sketchybar/plugins/aerospace_workspaces.sh" = {
    source = ../config/sketchybar/plugins/aerospace_workspaces.sh;
    executable = true;
  };
  home.file.".config/sketchybar/plugins/aerospace_toggle.sh" = {
    source = ../config/sketchybar/plugins/aerospace_toggle.sh;
    executable = true;
  };
  home.file.".config/sketchybar/plugins/front_app.sh" = {
    source = ../config/sketchybar/plugins/front_app.sh;
    executable = true;
  };
  home.file.".config/sketchybar/plugins/wifi.sh" = {
    source = ../config/sketchybar/plugins/wifi.sh;
    executable = true;
  };
  home.file.".config/sketchybar/plugins/battery.sh" = {
    source = ../config/sketchybar/plugins/battery.sh;
    executable = true;
  };
  home.file.".config/sketchybar/plugins/load.sh" = {
    source = ../config/sketchybar/plugins/load.sh;
    executable = true;
  };
  home.file.".config/borders/bordersrc" = {
    source = ../config/borders/bordersrc;
    executable = true;
  };
  home.file.".config/ghostty/config".source = ../config/ghostty/config;
  home.file.".config/keyboard-shortcuts.md".source = ../docs/keyboard-shortcuts.md;
  home.file.".local/bin/dotfiles-install" = {
    source = ../scripts/install;
    executable = true;
  };
  home.file.".local/bin/dotfiles-update" = {
    source = ../scripts/update;
    executable = true;
  };
  home.file.".local/bin/dotfiles-start-desktop" = {
    source = ../scripts/start-desktop;
    executable = true;
  };
  home.file.".local/bin/dotfiles-apply-latest" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      profile="''${1:-personal}"
      darwin-rebuild switch --flake "github:Nu11ified/dotfiles#$profile"
    '';
  };
}
