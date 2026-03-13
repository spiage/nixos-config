{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ../profiles/common.nix
    ../profiles/laptop.nix
  ];

  networking.hostName = "z1";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5a458e59-b6cc-4b99-bf5b-17e4ff9fa464";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/DD76-87F5";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/1f3153b7-1c56-42ea-8938-50a5fbb9ed85"; }
  ];

  # Intel GPU
  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = lib.mkForce false;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # Датчики
  hardware.sensor.iio.enable = true;

  # Plasma 6 + Wayland
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:win_space_toggle";

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "spiage";

  services.libinput.enable = true;
  services.fwupd.enable = true;

  # Шрифты
  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    terminus_font
    cascadia-code
  ];

  # Принтеры и сканеры
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.printing.enable = true;

  # Звук
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Пользователи
  users.users.spiage = {
    isNormalUser = true;
    description = "spiage";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "audio" "incus-admin" "kvm" "libvirtd" "vboxusers" "video" "docker" ];
  };

  # Пакеты
  environment.systemPackages = with pkgs; [
    inxi
    hw-probe
    nix-tree
    remmina
    usbutils
    vlc
    nvd
    btop
    fastfetch
    bridge-utils
    wget
    inetutils
    mc
    git
    google-chrome
    kdePackages.plasma-workspace-wallpapers
    pavucontrol
    kdePackages.ktorrent
    mpv
    kdePackages.dragon
    kdePackages.kcalc
    kdePackages.skanpage
    kdePackages.konsole
    lm_sensors
    ffmpeg
  ];

  services.openssh.enable = true;

  system.stateVersion = lib.mkForce "24.11";
}
