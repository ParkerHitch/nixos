{ config, pkgs, lib, nix-colors, ... }:
{

  imports = [
    nix-colors.homeManagerModules.default
    ./cli-programs
    ./gui-programs
    ./desktop-env
  ];

  home.username = "phitch";
  home.homeDirectory = "/home/phitch";

  home.sessionVariables = {
    NH_FLAKE =
      "${config.home.homeDirectory}/.config/nixos"; # config directory for nh
  };

  # Nix-Colors stuff
  colorScheme = nix-colors.colorSchemes.everforest;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Core apps
    brightnessctl
    wl-clipboard
    overskride

    # Basic cli tools
    ripgrep
    tree
    unzip
    fd
    jq

    # Actual dev stuff
    gcc
    clang-tools

    # Secret management. Originally installed for git
    libsecret
    gnome-keyring
    git-credential-manager

    # Fonts
    nerd-fonts.fira-code 

    # Nixos stuff
    nh
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # Also let home manager manage bash (useful for env stuff)
  programs.bash.enable = true;

  # Enable fonts
  fonts.fontconfig.enable = true;

  # Services
  services.gnome-keyring.enable = true;
  # Persistent clipboard
  systemd.user.services.wl-clip-persist = {
    Unit = {
      Description = "Persistent clipboard for Wayland";
      PartOf = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service.ExecStart = "${lib.getExe pkgs.wl-clip-persist} --clipboard both";
  };

  # Custom modules
  modules.firefox.enable = true;
  modules.ghostty.enable = true;
  modules.ghostty.useBase16 = true;
  modules.nvim.enable = true;
  modules.nvim.dotfileRepo = "https://github.com/ParkerHitch/nvim-config.git";


  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.
}
