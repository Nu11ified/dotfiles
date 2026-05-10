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
      cleanup = "zap";
    };
    taps = [
      "nikitabobko/tap"
      "cmacrae/formulae"
    ];
    brews = [
      "zsh-autosuggestions"
      "cmacrae/formulae/spacebar"
      "television"
    ];
    casks = [
      "ghostty"
      "emacs-app"
      "nikitabobko/tap/aerospace"
    ];
  };

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "Nlsv";
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.InitialKeyRepeat = 15;
  };

  system.stateVersion = 6;
}
