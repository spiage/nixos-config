{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

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

  # Используем существующий домен k8s.local
  homeDomain = "k8s.local";

  kubeMasterIP = "192.168.1.2";
  kubeMasterHostname = "a7.${homeDomain}";

  # Общие хосты для всех машин
  coreHosts = [
    "${kubeMasterIP} ${kubeMasterHostname}"
    "136.243.168.226 download.qt.io"
    "192.168.122.60 u2004-01"
    "192.168.1.2   a7 a7.${homeDomain}"
    "192.168.1.201 i9 i9.${homeDomain}"
    "192.168.1.15  i7 i7.${homeDomain}"
    "192.168.1.16  j4 j4.${homeDomain}"
    "192.168.1.18  q1 q1.${homeDomain}"
  ];

  # Виртуальные машины (добавляются в extraHosts)
  vmHosts = [
    "192.168.1.111 gitlab-01 gitlab-01.${homeDomain}"
    "192.168.1.110 grafana-01 grafana-01.${homeDomain}"
  ];

in
{

  # documentation.nixos.enable = false; # temporaty workaround for build issue

  time.timeZone = "Europe/Moscow";

  imports = [
    ../profiles/network/ntp-client.nix
    # ../profiles/vxlan.nix # не работает, перепробовал всякое :(
    # ../profiles/ceph.nix # временно отключен
  ];

  services.prometheus.exporters.node.enable = true;
  services.prometheus.exporters.node.port = 9103;

  # vxlan.enable = true;

  # Общие настройки для всех хостов
  networking.domain = homeDomain;
  networking.search = [ homeDomain ];
  networking.useNetworkd = true; # Полный переход на systemd-networkd
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    links = {
      "10-eth0" = {
        matchConfig.MACAddress = lib.mkDefault "00:00:00:00:00:00"; # Переопределяется в хостах
        linkConfig.Name = "eth0";
      };
    };
    netdevs = {
      "20-br0" = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
        };
        bridgeConfig = {
          STP = true;
          ForwardDelaySec = 4;
        };
      };
    };
    networks = {
      # Конфигурация для физического интерфейса eth0
      "20-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          Bridge = "br0";
          Description = "Physical interface bridged to br0";
        };
        linkConfig.RequiredForOnline = "no";
      };

      # Основная конфигурация сети на бридже
      "30-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          DHCP = "no";
          # DNS будет настроен индивидуально на каждом хосте
          ConfigureWithoutCarrier = true;
        };
        # Шлюз и адрес перенесены в host-specific конфиги
      };
    };
  };

  # Объединенные хосты: основные + VM
  networking.extraHosts = lib.concatStringsSep "\n" (coreHosts ++ vmHosts);

  boot.supportedFilesystems = [
    "ntfs"
    "btrfs"
    "ext4"
    "xfs"
    "zfs"
  ];
  boot.kernelPackages = latestKernelPackage;
  boot.swraid.enable = false;
  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  hardware.enableRedistributableFirmware = lib.mkDefault true; # lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.bluetooth.enable = true;
  hardware.usb-modeswitch.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  networking.networkmanager.enable = false;

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

  nixpkgs.overlays = [
    (final: prev: {
      libvirt = prev.libvirt.override {
        enableXen = false;
        enableGlusterfs = false;
        enableIscsi = false;
      };
    })
  ];

  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
    qemu.package = pkgs.qemu_kvm;
    allowedBridges = [
      "virbr1"
      "virbr0"
      "br0"
      "br-vxlan"
    ];
  };
  #The 'virtualisation.libvirtd.qemu.ovmf' submodule has been removed. All OVMF images distributed with QEMU are now available by default.
  # virtualisation.libvirtd.qemu.ovmf.packages = [
  #   (pkgs.OVMF.override {
  #     secureBoot = true;
  #     tpmSupport = true;
  #   }).fd
  # ];

  services.rpcbind.enable = true; # needed for NFS
  systemd.mounts =
    let
      commonMountOptions = {
        type = "nfs";
        mountConfig = {
          Options = "noatime";
        };
      };

    in

    [
      (
        commonMountOptions
        // {
          what = "j4:/vpool";
          where = "/mnt/nfs";
        }
      )
    ];

  systemd.automounts =
    let
      commonAutoMountOptions = {
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

  virtualisation.docker.extraOptions = ''--iptables=false --ip-masq=false -b br0'';

  environment.systemPackages = with pkgs; [

    ncdu # Disk usage analyzer with an ncurses interface

    dig

    cloud-utils

    tcpdump
    iperf3

    bridge-utils
    wget

    nfs-utils # This package contains various Linux user-space Network File System (NFS) utilities, including RPC mount' and nfs’ daemons.
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
    # hw-probe
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
    rustic
    borgbackup
    pika-backup
    rclone
    smartmontools
    nut
  ];

  networking.firewall.enable = false;
  networking.firewall.allowPing = true;
  networking.networkmanager.unmanaged = [
    "virbr1"
    "virbr0"
    "br0"
    "br-vxlan"
    "eth0"
  ];
  networking.firewall.allowedTCPPorts = [
    2049 # NFSv4
    49152 # libvirt live migration direct connect
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    8080
    3000
    9100 # found input from a7
    10250 # found input from i9
    7946 # found
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
    4789 # VXLAN
  ];
  system.stateVersion = "24.05"; # Did you read the comment?
}
