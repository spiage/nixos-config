{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

let
  # zfsCompatibleKernelPackages = lib.filterAttrs (
  #   name: kernelPackages:
  #   (builtins.match "linux_[0-9]+_[0-9]+" name) != null
  #   && (builtins.tryEval kernelPackages).success
  #   && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  # ) pkgs.linuxKernel.packages;
  # latestKernelPackage = lib.last (
  #   lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
  #     builtins.attrValues zfsCompatibleKernelPackages
  #   )
  # );

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
    "192.168.1.144 f1 f1.${homeDomain}"
  ];

  # Виртуальные машины (добавляются в extraHosts)
  vmHosts = [
    "192.168.1.111 gitlab-01 gitlab-01.${homeDomain}"
    "192.168.1.110 grafana-01 grafana-01.${homeDomain}"
  ];

in
{

  # nix.package = pkgs.nixVersions.latest;

  imports = [
    ../profiles/common.nix
    # ../profiles/vxlan.nix # не работает, перепробовал всякое :(
    # ../profiles/ceph.nix # временно отключен
  ];

  services.prometheus.exporters.node.enable = true;
  services.prometheus.exporters.node.port = 9103;

  # vxlan.enable = true;

  # Общие настройки для всех хостов
  networking.domain = homeDomain;
  networking.search = [ "~." homeDomain ];
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

  networking.networkmanager.enable = false;

  nixpkgs.overlays = [
    (final: prev: {
      libvirt = prev.libvirt.override {
        enableXen = false;
        enableGlusterfs = false;
        enableIscsi = false;
      };
    })
  ];

  # virtualisation.waydroid.enable = true;
  # virtualisation.waydroid.package = pkgs.waydroid-nftables;

  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
    qemu.package = pkgs.qemu_kvm;
    qemu.swtpm.enable = true;
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

  # systemd.mounts =
  #   let
  #     commonMountOptions = {
  #       type = "nfs";
  #       mountConfig = {
  #         Options = "noatime";
  #       };
  #     };

  #   in

  #   [
  #     (
  #       commonMountOptions
  #       // {
  #         what = "j4:/vpool";
  #         where = "/mnt/nfs";
  #       }
  #     )
  #   ];

  # systemd.automounts =
  #   let
  #     commonAutoMountOptions = {
  #       wantedBy = [ "multi-user.target" ];
  #       automountConfig = {
  #         TimeoutIdleSec = "600";
  #       };
  #     };

  #   in

  #   [
  #     (commonAutoMountOptions // { where = "/mnt/nfs"; })
  #     # (commonAutoMountOptions // { where = "/mnt/oyomot"; })
  #   ];


  virtualisation.docker.extraOptions = ''--iptables=false --ip-masq=false -b br0'';

  environment.systemPackages = with pkgs; [

    # nemu # Ncurses UI for QEMU

    cloud-utils

    bridge-utils
    # hw-probe
    inxi
    # phoronix-test-suite     yasm     nasm cmake unzip x264 ## $phoronix-test-suite benchmark build-ffmpeg
    # geekbench
    # restic # Backup program that is fast, efficient and secure
    # rustic # Fast, encrypted, deduplicated backups powered by pure Rust
    # borgbackup
    # pika-backup
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
