{ config, pkgs, username, profile, ... }:

{
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  system.primaryUser = username;

  users.users.${username}.home = "/Users/${username}";

  environment.systemPackages = with pkgs; [
    git
    vim
    neovim
    tmux
    ripgrep
    fd
    fzf
    bat
    eza
    starship
    tldr
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  programs.zsh.enable = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
    brews = [
      "cloud-sql-proxy"
      "felixkratz/formulae/borders"
      "git"
      "postgresql@16"
      "felixkratz/formulae/sketchybar"
      "starship"
      "zsh-autosuggestions"
      "television"
    ];
    casks = [
      "bruno"
      "codex"
      (if profile == "personal" then "orbstack" else "docker-desktop")
      "ghostty"
      "gcloud-cli"
      "emacs-app"
      "font-caskaydia-cove-nerd-font"
      "font-fira-mono-nerd-font"
      "font-iosevka-term-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "nikitabobko/tap/aerospace"
      "tableplus"
    ];
  };

  system.activationScripts.preActivation.text = ''
    brew="${config.homebrew.prefix}/bin/brew"
    if [ -x "$brew" ]; then
      /usr/bin/sudo --user=${username} --set-home "$brew" trust --formula felixkratz/formulae/borders >/dev/null
      /usr/bin/sudo --user=${username} --set-home "$brew" trust --formula felixkratz/formulae/sketchybar >/dev/null
      /usr/bin/sudo --user=${username} --set-home "$brew" trust --cask nikitabobko/tap/aerospace >/dev/null
    fi
  '';

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "Nlsv";
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain._HIHideMenuBar = true;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.InitialKeyRepeat = 15;
    universalaccess.reduceTransparency = true;
  };

  power.sleep = {
    display = 5;
    harddisk = 10;
  };

  system.stateVersion = 6;
}
