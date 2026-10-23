{ config, pkgs, inputs, lib, ... }:
{

  imports = [
    ../profiles/boot/systemd-boot.nix
    ../profiles/homelab.nix
    ../profiles/laptop.nix
    ../profiles/network/dns-client.nix
    ../profiles/desktop/fonts.nix
    ../profiles/desktop/plasma6.nix
    ../profiles/desktop/printing.nix
    ../profiles/desktop/pipewire.nix
    ../profiles/desktop/packages.nix
    ../profiles/hardware/graphics.nix
  ];

  systemd.network = {
    links."10-eth0".matchConfig.MACAddress = lib.concatStringsSep " " [
      # Объединение через пробел
      "98:29:a6:3f:cc:40" # Физический интерфейс
    ];

    networks = {
      "30-br0" = {
        address = [
          "192.168.1.115/16"
          # Для IPv6 (если нужно):
          # "2001:db8::a7/64"
        ];
        networkConfig = {
          DNS = "192.168.1.18"; # DNS-сервер q1
          Gateway = "192.168.1.1";
          Domains = ["~."];
        };
      };
    };
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];
  # boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/fd453190-5e45-4c7e-aae2-6977029b8069";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/99C2-9A53";
      fsType = "vfat";
    };

  # swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" "btrfs" "ext4" ];
  boot.initrd.kernelModules = [ "nvidia" "i915" ];

  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.bluetooth.enable = true;
  hardware.usb-modeswitch.enable = true;

  boot.swraid.enable = false;
  networking.hostName = "i5"; # Define your hostname.

  # networking.extraHosts =
  #   ''
  #     136.243.168.226 download.qt.io
  #   '';

  time.timeZone = "Europe/Moscow";

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
    font = "ter-v16n";
    keyMap = "ru";
    earlySetup = true;
  };

  services.xserver.enable = true;
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:win_space_toggle";
  services.xserver.videoDrivers = [ "nvidia" "intel" ];
  services.xserver.libinput.enable = true;


  programs.partition-manager.enable = true;
  # services.dbus.packages = [ pkgs.libsForQt5.kpmcore ];

  programs.kdeconnect.enable = true;

 
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

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
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "audio" "incus-admin" "kvm" "libvirtd" "vboxusers" "video" ];
  };

  nixpkgs.config.allowUnfree = true;

  programs.traceroute.enable = true;
  environment.systemPackages = with pkgs; [
    mc
    oh-my-git

    git     

    kdePackages.partitionmanager

    # libsForQt5.qtstyleplugin-kvantum # inputs.kde2nix.packages.x86_64-linux.qtstyleplugin-kvantum
    # libsForQt5.plasma-workspace-wallpapers #collision with konsole from plasma 5 inputs.kde2nix.packages.x86_64-linux.plasma-workspace-wallpapers

    pavucontrol # libsForQt5.kmix deprecated #marked broken inputs.kde2nix.packages.x86_64-linux.kmix    
    # libsForQt5.kcmutils # inputs.kde2nix.packages.x86_64-linux.kcmutils
    remmina # libsForQt5.krdc !vvv remmina is faster vvv!
    # libsForQt5.kpat # inputs.kde2nix.packages.x86_64-linux.kpat
    kdePackages.konsole
    kdePackages.skanpage
    kdePackages.ktorrent
    kdePackages.dragon
    kdePackages.kcalc
    kdePackages.kmines
    kdePackages.skanpage

    lm_sensors
    lsof

    fastfetch
    btop
    htop

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
    lshw


    wgetpaste

  ]
  ;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  hardware.opengl.enable = true;
  # hardware.opengl.driSupport = true;
  hardware.nvidia.prime = {
    reverseSync.enable = true;
    allowExternalGpu = false;

    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.openssh.enable = true;

  system.stateVersion = lib.mkForce "23.05"; # Did you read the comment?

}
