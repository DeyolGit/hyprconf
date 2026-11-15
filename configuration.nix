{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ── Boot ────────────────────────────────────────────────────────────
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
    configurationLimit = 10; # keeps /boot from filling up
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "exfat" ];
  # Resolution

  # ── Nix ─────────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nixpkgs.config.allowUnfree = true;

  # ── Networking ──────────────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager = {
    enable = true; # only need this
  };
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  # Network printer
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  programs.localsend = {
    enable = true;
    openFirewall = true; # port 53317
  };

  # ── Locale ──────────────────────────────────────────────────────────
  time.timeZone = "Europe/Belgrade";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ── Desktop (Hyprland) ──────────────────────────────────────────────
  programs.hyprland.enable = true; # also adds xdg-desktop-portal-hyprland
  services.displayManager.ly.enable = true;
  services.dunst.enable = true;
  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb"; # native Wayland, fall back to XWayland
    NIXOS_OZONE_WL = "1";            # Electron apps
  };

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
    inter
  ];

  # ── Hardware ────────────────────────────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # ── Gaming ──────────────────────────────────────────────────────────
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  # ── Users & shell ───────────────────────────────────────────────────
  programs.fish.enable = true;

  users.users.mihailo = {
    isNormalUser = true;
    description = "mihailo";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  # ── Misc programs ───────────────────────────────────────────────────
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # ── Packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Desktop tools
    dunst # notis
    hyprpolkitagent
    hyprpicker
    hyprshot
    quickshell
    nwg-look
    nwg-displays
    wl-clipboard
    brightnessctl # laptop needs this
    libnotify # you need this
    networkmanagerapplet
    pavucontrol

    # Theming
    gnome-themes-extra
    papirus-icon-theme
    whitesur-gtk-theme
    whitesur-icon-theme

    # Apps
    alacritty
    nautilus
    brave
    overskride
    discord
    viber
    spotify
    stremio-linux-shell
    libreoffice
    evince # PDF viewer
    loupe # Image viewer
    mpv
    vscode

    # Gaming    
    lutris
    wine

    # CLI
    neovim
    git
    wget
    curl
    unzip
    htop
    fzf
    nitch
    cmatrix

    # Dev
    rustc
    cargo
    gcc
    jdk21
    python314
  ];

  # Laptop:
  # services.power-profiles-daemon.enable = true;
  # services.upower.enable = true;

  system.stateVersion = "26.05"; # don't change after install
}

