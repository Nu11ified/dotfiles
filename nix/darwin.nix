{ pkgs, username, ... }:

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
      autoUpdate = true;
      upgrade = false;
      cleanup = "none";
    };
    taps = [
      "FelixKratz/formulae"
      "nikitabobko/tap"
    ];
    brews = [
      "borders"
      "git"
      "sketchybar"
      "starship"
      "zsh-autosuggestions"
      "television"
    ];
    casks = [
      "bruno"
      "codex"
      "ghostty"
      "emacs-app"
      "font-caskaydia-cove-nerd-font"
      "font-fira-mono-nerd-font"
      "font-iosevka-term-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "nikitabobko/tap/aerospace"
    ];
  };

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

  system.stateVersion = 6;
}
