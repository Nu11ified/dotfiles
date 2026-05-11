{ pkgs, username, profile, ... }:

{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    cmake
    libtool
    nil
    nixpkgs-fmt
    emacs-lsp-booster
  ];

  programs.home-manager.enable = true;

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

  home.file.".emacs.d/early-init.el".source = ../emacs/early-init.el;
  home.file.".emacs.d/init.el".source = ../emacs/init.el;
  home.file.".config/aerospace/aerospace.toml".source = ../config/aerospace/aerospace.toml;
  home.file.".config/aerospace/scripts/open-workspace" = {
    source = ../config/aerospace/scripts/open-workspace;
    executable = true;
  };
  home.file.".config/aerospace/scripts/sync-app-workspaces" = {
    source = ../config/aerospace/scripts/sync-app-workspaces;
    executable = true;
  };
  home.file.".config/sketchybar/sketchybarrc" = {
    source = ../config/sketchybar/sketchybarrc;
    executable = true;
  };
  home.file.".config/sketchybar/plugins/aerospace.sh" = {
    source = ../config/sketchybar/plugins/aerospace.sh;
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
