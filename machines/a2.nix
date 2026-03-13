{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ../profiles/common.nix
    ../profiles/laptop.nix
  ];

  networking.hostName = "a2";

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/377c7a32-d8aa-4aae-99f9-2065d8959fc2";
      fsType = "ext4";
    };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_1; # GMA500: blackscreen на новых ядрах

  # Blacklist i915 для GMA500
  boot.blacklistedKernelModules = [ "i915" ];
  boot.kernelParams = [
    "brcmsmac.allhwsupport=1"
    "brcmsmac.qos=0"
    "thermal.nocrt=1"
    "video=LVDS-1:1024x600@60"
    "fbcon=font:TER12x24"
    "acpi_enforce_resources=lax"
    "intel_idle.max_cstate=1"
    "processor.max_cstate=1"
    "gma500.modeset=1"
    "acpi_osi=Linux"
  ];

  # Оптимизация для 2 ядер/4 потоков
  boot.kernel.sysctl = {
    "vm.swappiness" = 60;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    "kernel.sched_migration_cost_ns" = 5000000;
  };

  # i3wm + LightDM
  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
      ];
    };
    displayManager.lightdm.enable = true;
    displayManager.sessionCommands = ''
      ${pkgs.xset}/bin/xset s off -dpms
    '';
    xkb.layout = "us,ru";
    xkb.options = "grp:win_space_toggle";
  };

  services.displayManager.defaultSession = "none+i3";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "spiage";

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
    nerd-fonts.terminess-ttf
    cascadia-code
    dejavu_fonts
    freefont_ttf
    gyre-fonts
    unifont
  ];

  # Принтеры и сканеры
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.ipv6 = false;
  services.printing.enable = true;

  # Звук
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
  ];

  programs.starship.enable = true;
  programs.starship.presets = [ "nerd-font-symbols" ];

  # Пакеты
  environment.systemPackages = with pkgs; [
    x11vnc
    mc
    btop
    pciutils
    mesa-demos
    hw-probe
    inxi
    usbutils
    htop
    git
    inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable
    google-chrome
    weston
    glmark2
    st
    maim
    slop
    flameshot
    alacritty
    fastfetch
  ];

  zramSwap.enable = true;
  zramSwap.memoryPercent = 40;
  services.fstrim.enable = true;

  system.stateVersion = lib.mkForce "23.11";
}
