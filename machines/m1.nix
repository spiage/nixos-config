# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "i915" ];

  boot.kernelParams = [
    "i915.force_probe=46d2"
    "fbcon=rotate:1"
    "video=DSI-1:panel_orientation=right_side_up"
  ];

  hardware.sensor.iio.enable = true;


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.bluetooth.enable = true;
  hardware.usb-modeswitch.enable = true;

  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = lib.mkForce false;
    extraPackages = with pkgs; [
      # your Open GL, Vulkan and VAAPI drivers
      intel-media-driver
#      vpl-gpu-rt # or 
#      intel-media-sdk
    ];
  };



  boot.swraid.enable = false;

  networking.hostName = "m1"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };
  i18n = {
    defaultLocale = "ru_RU.UTF-8";
    supportedLocales = [ "ru_RU.UTF-8/UTF-8" ];
  };

  console = {
    packages = with pkgs; [ terminus_font ];
    font = "ter-v32n";
    keyMap = "ru";
    earlySetup = true;
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesettings" ];
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:win_space_toggle";

#   services.xserver.desktopManager.plasma5.enable = true;
  services.desktopManager.plasma6.enable = true;
#  services.displayManager.defaultSession = "plasmax11";

  services.displayManager.sddm.enable = true;
#  services.displayManager.sddm.wayland.enable = false;
   services.displayManager.sddm.wayland.enable = true;
#  services.displayManager.sddm.settings.General.DisplayServer = "x11-user";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "spiage";


  services.libinput.enable = true;
  services.fwupd.enable = true;

  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    # nerdfonts
    terminus_font
    nerd-fonts.terminess-ttf
    # terminus-nerdfont
    cascadia-code 
  ];

  #scanner
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  ###

  services.printing.enable = true;

  # sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  users.users.spiage = {
    isNormalUser = true;
    description = "spiage";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "audio" "incus-admin" "kvm" "libvirtd" "vboxusers" "video" "docker" ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.obs-studio.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    remmina
    freerdp3

    usbutils
    vlc
    nvd
    btop
    fastfetch

    bridge-utils 
    wget

    inetutils
    micro
    helix
    st
    libreoffice-qt
    # vmware-horizon-client

    microsoft-edge
    inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable  
    # yandex-browser
    google-chrome

    telegram-desktop

    mc
    oh-my-git

    git     
    vscode     

    #hw-probe
    #phoronix-test-suite     yasm     nasm cmake unzip x264 ## $phoronix-test-suite benchmark build-ffmpeg
    #geekbench
  ];

  services.openssh.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?

}
