{ pkgs, config, lib, inputs, ... }:
{

  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;
  boot.kernel.sysctl = { 
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
  };

  boot.supportedFilesystems = [ "ntfs" "btrfs" "ext4" "xfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.swraid.enable = false;
  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  hardware.enableRedistributableFirmware = lib.mkDefault true; #lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.bluetooth.enable = true;
  hardware.usb-modeswitch.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;

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
  
  users.users.spiage = {
    isNormalUser = true; 
    description = "spiage";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "audio" "incus-admin" "kvm" "libvirtd" "vboxusers" "video" ];
  };

  programs.traceroute.enable = true;
  programs.iotop.enable = true;
  programs.tmux.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.onShutdown = "shutdown";
  virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;
  virtualisation.libvirtd.qemu.ovmf.packages = [
    (pkgs.OVMF.override {
      secureBoot = true;
      tpmSupport = true;
    }).fd
  ];

  services.rsyncd.enable = true;
  services.openssh.enable = true;
 
  environment.systemPackages = with pkgs; [
    inetutils
    mc
    git    
    jq        
    lm_sensors
    lsof
    neofetch 
    fastfetch
    btop
    htop
    nix-tree
    nvd
    p7zip
    rar
    fwupd
    nvme-cli
    hw-probe
    inxi
    dmidecode
    clinfo
    pciutils
    zenstates
    wgetpaste
    phoronix-test-suite     yasm     nasm cmake unzip x264 ## $phoronix-test-suite benchmark build-ffmpeg
    geekbench
    rsync
    restic
    rustic-rs
    borgbackup pika-backup
    rclone
    smartmontools
    nut
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}