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
    taps = [
      "rjyo/moshi"
    ];
    brews = [
      "bitwarden-cli"
      "cloud-sql-proxy"
      "displayplacer"
      "felixkratz/formulae/borders"
      "git"
      "herdr"
      "mosh"
      "postgresql@16"
      "rjyo/moshi/moshi-hook"
      "felixkratz/formulae/sketchybar"
      "starship"
      "tmux"
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
      "slack"
      "tableplus"
      "warp"
      "wispr-flow"
    ];
  };

  system.activationScripts.preActivation.text = ''
    brew="${config.homebrew.prefix}/bin/brew"
    if [ -x "$brew" ]; then
      /usr/bin/sudo --user=${username} --set-home "$brew" tap rjyo/moshi >/dev/null
      /usr/bin/sudo --user=${username} --set-home "$brew" trust --tap rjyo/moshi >/dev/null
      /usr/bin/sudo --user=${username} --set-home "$brew" trust --formula felixkratz/formulae/borders >/dev/null
      /usr/bin/sudo --user=${username} --set-home "$brew" trust --formula felixkratz/formulae/sketchybar >/dev/null
      /usr/bin/sudo --user=${username} --set-home "$brew" trust --cask nikitabobko/tap/aerospace >/dev/null
    fi

    # Keep the Mac awake on wall power while still allowing display sleep.
    /usr/bin/pmset -c sleep 0
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
    spaces.spans-displays = true;
    # Needs Full Disk Access for the activating terminal; without it `defaults`
    # exits non-zero and aborts activation before home-manager ever runs.
    # The value is already set to 1 on this machine and persists without this line.
    # universalaccess.reduceTransparency = true;
  };

  power.sleep = {
    display = 5;
    harddisk = 10;
  };

  system.stateVersion = 6;
}
