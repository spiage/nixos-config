{ pkgs, config, lib, inputs, ... }:

let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
  homeDomainName = "k8s.local";
in
{

  # zramSwap.enable = true;
  # zramSwap.memoryPercent = 100;
  # boot.kernel.sysctl = { 
  #   "vm.swappiness" = 180;
  #   "vm.page-cluster" = 0;
  # };

  boot.supportedFilesystems = [ "ntfs" "btrfs" "ext4" "xfs" "zfs" ];
  boot.kernelPackages = latestKernelPackage;
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
  networking.networkmanager.plugins = lib.mkForce [ ];
  ### default plugins are:
        # networkmanager.plugins = with pkgs; [
        #   networkmanager-fortisslvpn
        #   networkmanager-iodine
        #   networkmanager-l2tp
        #   networkmanager-openconnect
        #   networkmanager-openvpn
        #   networkmanager-vpnc
        #   networkmanager-sstp
        # ];
  networking.networkmanager.appendNameservers = [ "192.168.1.1" ];
  networking.useDHCP = lib.mkDefault true;
  networking.extraHosts =
    ''
      192.168.1.2   a7 a7.${homeDomainName}
      192.168.1.201 i9 i9.${homeDomainName}
      192.168.1.15  i7 i7.${homeDomainName}
      192.168.1.16  j4 j4.${homeDomainName}
      192.168.1.18  q1 q1.${homeDomainName}
    '';

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
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "audio" "incus-admin" "kvm" "libvirtd" "vboxusers" "video" "docker" ];
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

  services.rpcbind.enable = true; # needed for NFS
  systemd.mounts = let commonMountOptions = {
    type = "nfs";
    mountConfig = {
      Options = "noatime";
    };
  };

  in

  [
    (commonMountOptions // {
      what = "j4:/vpool";
      where = "/mnt/nfs";
    })

    # (commonMountOptions // {
    #   what = "server:/oyomot";
    #   where = "/mnt/oyomot";
    # })
  ];

  systemd.automounts = let commonAutoMountOptions = {
    wantedBy = [ "multi-user.target" ];
    automountConfig = {
      TimeoutIdleSec = "600";
    };
  };

  in

  [
    (commonAutoMountOptions // { where = "/mnt/nfs"; })
    # (commonAutoMountOptions // { where = "/mnt/oyomot"; })
  ];  

  services.rsyncd.enable = true;
  services.openssh.enable = true;

  virtualisation.docker.extraOptions =
    ''--iptables=false --ip-masq=false -b br0'';

  environment.systemPackages = with pkgs; [

    bridge-utils 
    wget

    nfs-utils #This package contains various Linux user-space Network File System (NFS) utilities, including RPC mount' and nfs’ daemons.
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
    # phoronix-test-suite     yasm     nasm cmake unzip x264 ## $phoronix-test-suite benchmark build-ffmpeg
    # geekbench
    rsync
    restic
    rustic-rs
    borgbackup pika-backup
    rclone
    smartmontools
    nut
  ];

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 
    2049 #NFSv4
    49152 #libvirt live migration direct connect
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    9100 # found input from a7
    10250 # found input from i9
    7946 # found
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  system.stateVersion = "24.05"; # Did you read the comment?
}