{ pkgs, username, ... }:

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
    };
    initContent = ''
      export ZSH="$HOME/dotfiles/oh-my-zsh"
      export ZSH_CUSTOM="$HOME/dotfiles/zsh/zsh-custom"
      export PATH="$HOME/.local/bin:$PATH"

      if [ -d "$ZSH" ]; then
        plugins=(git starship)
        source "$ZSH/oh-my-zsh.sh"
      fi

      if [ -f "$ZSH_CUSTOM/aliases.zsh" ]; then
        source "$ZSH_CUSTOM/aliases.zsh"
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
  home.file.".config/spacebar/spacebarrc" = {
    source = ../config/spacebar/spacebarrc;
    executable = true;
  };
  home.file.".config/spacebar/scripts/aerospace-status" = {
    source = ../config/spacebar/scripts/aerospace-status;
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
