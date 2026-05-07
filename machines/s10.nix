{ config, lib, pkgs, inputs, ... }:

{

  imports = [
    ../profiles/common.nix
    ../profiles/laptop.nix
  ];

  networking.hostName = "s10"; 

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "usb_storage" "ums_realtek" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/22e690d4-7687-4d0a-827b-466907e50b29";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/1ec43a56-6b71-42b6-aa3f-15eebf3d7c61"; }
    ];

  nixpkgs.hostPlatform = lib.mkForce "i686-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_15;

  nixpkgs.overlays = [
    (final: prev: {
      efivar = prev.stdenv.mkDerivation {
        name = "efivar-stub";
        phases = [ "installPhase" ];
        installPhase = "mkdir -p $out";
      };
      efibootmgr = prev.stdenv.mkDerivation {
        name = "efibootmgr-stub";
        phases = [ "installPhase" ];
        installPhase = "mkdir -p $out";
      };
      nix = prev.nix.overrideAttrs (_: {
        doCheck = false;
      });
      i3 = prev.i3.overrideAttrs (_: {
        doCheck = false;
      });
      iniparser = prev.iniparser.overrideAttrs (_: {
        doCheck = false;
      });      
      perlPackages = prev.perlPackages // {
        Test2-Harness = prev.perlPackages.Test2-Harness.overrideAttrs (old: {
          doCheck = false;
        });
      };
    })
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

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
  # fonts.packages = with pkgs; [
  #   noto-fonts
  #   noto-fonts-cjk-sans
  #   noto-fonts-color-emoji
  #   liberation_ttf
  #   fira-code
  #   fira-code-symbols
  #   mplus-outline-fonts.githubRelease
  #   dina-font
  #   proggyfonts
  #   terminus_font
  #   nerd-fonts.terminess-ttf
  #   cascadia-code
  #   dejavu_fonts
  #   freefont_ttf
  #   gyre-fonts
  #   unifont
  # ];

  # Принтеры и сканеры
  # hardware.sane.enable = true;
  # hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  # services.avahi.enable = true;
  # services.avahi.nssmdns4 = true;
  # services.avahi.ipv6 = false;
  # services.printing.enable = true;

  # Звук
  # services.pulseaudio.enable = false;
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   pulse.enable = true;
  # };

  services.libinput.enable = true;

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
  ];

  # programs.starship.enable = true;
  # programs.starship.presets = [ "nerd-font-symbols" ];

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
    glmark2
    maim
    slop
    # flameshot требует qtwebengine
    alacritty
    fastfetch
  ];

  zramSwap.enable = true;
  zramSwap.memoryPercent = 40;
  services.fstrim.enable = true;

  system.stateVersion = lib.mkForce "26.05"; # Did you read the comment?

}

