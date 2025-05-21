# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:
let
  hyprlandnix = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.asahi.peripheralFirmwareDirectory = ../../firmware;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "mainm1"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.iwd = {
  #   enable = true;
  #   settings.General.EnableNetworkConfiguration = true;
  # };

  # Set your time zone.
  services.automatic-timezoned.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Setup users. Used mkpasswd in temp shell for hash
  users.mutableUsers = false;
  users.users.phitch = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$sVMh/zVpd2NtjVeetKPYQ/$cxoNhAfyyJyOqH8gCnWOut5cn101pdxE5nacYFmdtC1";
    extraGroups = [ 
                    "wheel" # Enable ‘sudo’ for the user.
                    "networkmanager"
                  ]; 
    shell = pkgs.fish;
  };
  # Give myself fish
  programs.fish.enable = true;

  # System packages for use in emergency
  environment.systemPackages = with pkgs; [ vim wget ];

  # Setup hyprland
  # Based on: wiki.hyprland.org/Nix/Hyprland-on-NixOS
  # Need their cachix so I don't have to recompile mesa + ffmpeg
  nix.settings.substituters = [ "https://hyprland.cachix.org" ];
  nix.settings.trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  
  # Actually enable it. Configuration is done in home-manager
  programs.hyprland = {
    enable = true;
    # Use uwsm
    withUWSM = true;
    # X11 support
    xwayland.enable = true;

    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # Enable graphics and the notch!!!
  hardware.asahi.useExperimentalGPUDriver = true;
  hardware.graphics = {
    enable = true;
  }; 
  boot.kernelParams = [ "apple_dcp.show_notch=1" ];

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Display manager
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
 
  # Gnome-keyring for secrets. Make sure to enable it in home manager too
  services.gnome.gnome-keyring.enable = true;
  # security.pam.services.login.enableGnomeKeyring = true;

  # Font dir idk
  fonts.fontDir.enable = true;

  # Session variables
  environment.sessionVariables = {
    GSK_RENDERER = "ngl";
  };

  # Make sure our nixpkgs align with that of the flake
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

