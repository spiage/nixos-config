{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

{

  # documentation.nixos.enable = false; # temporaty workaround for build issue

  time.timeZone = "Europe/Moscow";

  imports = [
    ../profiles/network/ntp-client.nix
  ];

  boot.supportedFilesystems = [
    "ntfs"
    "btrfs"
    "ext4"
    "xfs"
    # "zfs"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest; # latestKernelPackage;
  # boot.kernelPackages = pkgs.linuxKernel.packagesFor (
  #   pkgs.linuxKernel.kernels.linux_7_0.override {
  #     argsOverride = rec {
  #       version = "7.0.6";
  #       modDirVersion = version;
  #       src = pkgs.fetchurl {
  #         url = "mirror://kernel/linux/kernel/v7.x/linux-${version}.tar.xz";
  #         sha256 = "sha256-y6REQKpXr/18ISQdxbwjSw31PEmfj/w+vCkN0zkKdSM="; 
  #       };
  #     };
  #   }
  # );

  boot.swraid.enable = false;
  # boot.initrd.systemd.enable = true; #  The option definition `boot.initrd.systemd.enable' in `/nix/store/f8annkzh81qrfpr54zk0zn78a902wg6c-source/profiles/common.nix' no longer has any effect; please remove it.
  boot.loader.systemd-boot.memtest86.enable = true;

  hardware.enableRedistributableFirmware = lib.mkDefault true; # lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.bluetooth.enable = true;
  # hardware.usb-modeswitch.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

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
    extraGroups = [
      "networkmanager"
      "wheel"
      "scanner"
      "lp"
      "audio"
      "incus-admin"
      "kvm"
      "libvirtd"
      "libvirt"
      "vboxusers"
      "video"
      "docker"
      "podman"
      "tsusers"
    ];
  };

  programs.traceroute.enable = true;
  programs.iotop.enable = true;
  programs.tmux.enable = true;

  services.rpcbind.enable = true; # needed for NFS

  services.rsyncd.enable = true;
  services.openssh.enable = true;
  # services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [

    ncdu # Disk usage analyzer with an ncurses interface

    dig

    tcpdump
    iperf3

    wget

    nfs-utils # This package contains various Linux user-space Network File System (NFS) utilities, including RPC mount' and nfs’ daemons.
    inetutils
    mc
    git
    jq
    lm_sensors
    lsof
    fastfetch
    btop
    htop
    nix-tree
    nvd
    p7zip
    rar
    # fwupd
    nvme-cli
    dmidecode
    clinfo
    pciutils
    zenstates
    wgetpaste
    rsync
  ];

  networking.firewall.enable = false;
  networking.firewall.allowPing = true;
  system.stateVersion = "24.05"; # Did you read the comment?
}
