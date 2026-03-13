{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ../profiles/common.nix
    ../profiles/laptop.nix
  ];

  networking.hostName = "s9";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/05550c8a-75d7-494a-bfa9-fcaaef1cf93c";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/405A-6EDC";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/f58f04a4-59f3-4a57-8fe2-cb87cbbbd7e1";
    fsType = "btrfs";
  };

  swapDevices = [ ];

  # Датчики
  hardware.sensor.iio.enable = true;

  # Plasma 6 + Wayland
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:win_space_toggle";
  services.xserver.libinput.enable = true;

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "spiage";

  # KDE Connect
  programs.kdeconnect.enable = true;

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
    terminus_font_ttf
    nerd-fonts.terminess-ttf
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
  users.users.taka = {
    isNormalUser = true;
    description = "taka";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "audio" "incus-admin" "kvm" "libvirtd" "vboxusers" "video" ];
  };

  # Пакеты
  environment.systemPackages = with pkgs; [
    inputs.max-messenger.packages.x86_64-linux.default
    inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable
    google-chrome
    telegram-desktop
    mc
    git
    vscode
    kdePackages.plasma-workspace-wallpapers
    pavucontrol
    kdePackages.ktorrent
    mpv
    kdePackages.dragon
    kdePackages.kcalc
    kdePackages.skanpage
    lm_sensors
    lsof
    ffmpeg
    fastfetch
    btop
    htop
    python3
    nix-tree
    nvd
    qdirstat
    p7zip
    rar
    fwupd
    nvme-cli
    hw-probe
    inxi
    dmidecode
    clinfo
    mesa-demos
    vulkan-tools
    gpu-viewer
    pciutils
    zenstates
  ];

  system.stateVersion = lib.mkForce "23.05";
}
