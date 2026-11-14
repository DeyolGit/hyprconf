{ config, pkgs, ... }:
let unstable = import <nixos-unstable> {}; in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "exfat" ];
  boot.loader.systemd-boot.consoleMode = "max";
  boot.kernelParams = [ "video=1920x1080@180" ];
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];   
  networking.networkmanager.dns = "none";
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  # Enable networking
  networking.networkmanager.enable = true;
  programs.hyprland.enable = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
};
 
  programs.localsend = {
    enable = true;
    openFirewall = true; # Automatically opens port 53317
  };
services.printing = {
  enable = true;
  drivers = [ pkgs.gutenprint ]; # Replace with specific driver if needed
};
services.avahi = {
  enable = true;
  nssmdns4 = true;
  openFirewall = true;
  publish = {
    enable = true;
    userServices = true;
  };
};
services.dunst.enable = true;
networking = {  
  resolvconf.enable = false; 
  firewall = {
  allowedTCPPorts = [ 631 ];
  allowedUDPPorts = [ 631 ];
};
};

environment.sessionVariables = {
    QT_QPA_PLATFORM = "xcb";
  };

  services.displayManager.ly.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    

  };

  xdg.portal = {
  enable = true;
  extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];
};


programs.steam.enable = true;


programs.fish.enable = true;
users.users.mihailo.shell = pkgs.fish;
security.rtkit.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."mihailo" = {
    isNormalUser = true;
    description = "mihailo";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.

   environment.systemPackages = with pkgs; [
     neovim 
     wget
     steam
     hyprland #WM
     pipewire #Audio
     blueman
     spotify
     dunst #Noti
     alacritty #Terminal
     fish #Shell
     nautilus #File Manager
     git
     evince
     brave #Browser
     font-awesome
     curl
     networkmanagerapplet
     nwg-look
     wl-clipboard
     brightnessctl
     nwg-displays
     unzip
     gnome-themes-extra
     nerd-fonts.jetbrains-mono
     jetbrains-mono
     overskride
     pavucontrol
     discord
     htop
     mpv
     viber
     jdk21
     libreoffice
     libnotify
     localsend
     loupe
     sassc
     cmatrix
     papirus-icon-theme
     papirus-folders
    hyprpicker
    hyprshot
    unstable.quickshell
    vscode
    gearlever
    wine
    fzf
    stremio-linux-shell
    rustc
    cargo
    gcc
    lutris
    python314
    nitch
  ];
  
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
  font-awesome
  nerd-fonts.jetbrains-mono
  jetbrains-mono
  inter
];


   programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

  # List services that you want to enable:

   services.openssh.enable = false;

  system.stateVersion = "26.05"; # Did you read the comment?

}
