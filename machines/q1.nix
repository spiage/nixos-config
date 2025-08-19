{
  config,
  lib,
  pkgs,
  ...
}:

{

  networking.hostName = "q1"; # Define your hostname.
  networking.hostId = "9c60a626";

  imports = [
    ../profiles/boot/systemd-boot.nix
    ../profiles/video/nvidia-simple.nix
    ../profiles/network/ntp-server-ru.nix
    ../profiles/network/dnsmasq.nix
    ../profiles/storage/ceph-common.nix
    ../profiles/common.nix
    ../profiles/k3s.nix
  ];

  # Специфичные настройки для q1
  services.ceph = {
    # Включаем только монитор
    mon = {
      enable = true;
      daemons = [ "q1" ]; # ID демона должен совпадать с monInitialMembers
    };

    # Явно отключаем ненужные сервисы
    mgr.enable = false;
    osd.enable = false;
    mds.enable = false;
    rgw.enable = false;
  };

  # Дополнительные настройки безопасности
  networking.firewall.allowedTCPPorts = [ 6789 ]; # Порт для мониторов

  # Systemd сервис для ручной инициализации MON (только первый раз)
  systemd.services."ceph-mon-init" = {
    enable = true;
    description = "Initialize Ceph Monitor on first boot";
    before = [ "ceph-mon-q1.service" ];
    requiredBy = [ "ceph-mon-q1.service" ];
    script =
      let
        ceph = pkgs.ceph;
      in
      ''
        # Создаем рабочий каталог с правильными правами
        mkdir -p /var/lib/ceph/mon/ceph-q1
        chown ceph:ceph /var/lib/ceph/mon/ceph-q1

        if ! [ -f /var/lib/ceph/mon/ceph-q1/keyring ]; then
          echo "Initializing Ceph Monitor q1"
          
          # Создаем временный keyring
          ${ceph}/bin/ceph-authtool --create-keyring /var/lib/ceph/mon/ceph-q1/keyring.tmp \
            --gen-key -n mon. --cap mon 'allow *'
          
          # Создаем monmap
          ${ceph}/bin/monmaptool --create --add q1 192.168.1.18 /var/lib/ceph/mon/ceph-q1/monmap
          
          # Инициализируем MON
          ${ceph}/bin/ceph-mon --mkfs -i q1 \
            --monmap /var/lib/ceph/mon/ceph-q1/monmap \
            --keyring /var/lib/ceph/mon/ceph-q1/keyring.tmp
          
          # Перемещаем временный keyring в постоянный
          mv /var/lib/ceph/mon/ceph-q1/keyring.tmp /var/lib/ceph/mon/ceph-q1/keyring
          
          # Создаем файл-маркер для systemd
          touch /var/lib/ceph/mon/ceph-q1/done
        else
          echo "Ceph Monitor already initialized"
        fi
      '';
    serviceConfig = {
      Type = "oneshot";
      User = "ceph";
      RemainAfterExit = true;
      StateDirectory = "ceph/mon/ceph-q1"; # Добавлено для корректных прав
    };
    wantedBy = [ "multi-user.target" ];
  };

  profiles.networking.dns-dhcp-server = {
    enable = true;
    forwarders = [
      "192.168.1.1" # Локальный роутер
      "1.1.1.1" # Cloudflare Primary
      "8.8.8.8" # Google Primary
      "9.9.9.9" # Quad9 (резервный)
    ];

    staticHosts = [
      # Основные хосты
      {
        mac = "20:7c:14:f4:21:34";
        ip = "192.168.1.18";
        name = "q1";
        description = "core";
      }
      {
        mac = "00:15:5d:01:02:00";
        ip = "192.168.1.2";
        name = "a7";
        description = "core";
      }
      {
        mac = "2c:f0:5d:29:f6:01";
        ip = "192.168.1.201";
        name = "i9";
        description = "core";
      }
      {
        mac = "a8:42:a1:ff:eb:e3";
        ip = "192.168.1.15";
        name = "i7";
        description = "core";
      }
      {
        mac = "f4:a4:54:87:66:ef";
        ip = "192.168.1.16";
        name = "j4";
        description = "core";
      }
      {
        mac = "74:56:3c:78:21:ad";
        ip = "192.168.1.11";
        name = "w11";
        description = "core";
      }
      # Виртуальные машины
      {
        mac = "52:54:00:63:03:64";
        ip = "192.168.1.101";
        name = "root-xfs-ubuntu-2024";
        description = "vm";
      }
      {
        mac = "52:54:00:73:ea:e9";
        ip = "192.168.1.110";
        name = "grafana-01";
        description = "vm";
      }
      {
        mac = "52:54:00:f5:65:bc";
        ip = "192.168.1.111";
        name = "gitlab-01";
        description = "vm";
      }
      {
        mac = "52:54:00:30:f9:1a";
        ip = "192.168.1.112";
        name = "prometheus-01";
        description = "vm";
      }

      # Дополнительные устройства
      # { mac = "c8:09:a8:11:99:be"; ip = "192.168.1.123"; name = "nas"; }
      # { mac = "a8:a1:59:ee:3b:ab"; ip = "192.168.1.124"; name = "iot-gateway"; }
    ];
  };

  # DNS для самого q1
  networking.nameservers = [
    "127.0.0.1" # Локальный Knot DNS
    "192.168.1.1" # Роутер (резерв)
  ];
  # Полное отключение systemd-resolved
  services.resolved.enable = false;
  # systemd.services.systemd-resolved.enable = false;
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
    nameserver 192.168.1.1
    search k8s.local
  '';
  # Конфигурация бриджа (остается без изменений)
  systemd.network = {
    links."10-eth0".matchConfig.MACAddress = "20:7c:14:f4:21:34";
    networks."30-br0" = {
      address = [ "192.168.1.18/16" ];
      networkConfig = {
        DNS = "127.0.0.1"; # Локальный DNS-сервер
        Gateway = "192.168.1.1";
      };
    };
  };
  # services.ntp-ru.enable = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c39c8bb9-7bcc-4259-a79b-53299fa48238";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0307-F9E8";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # swapDevices =
  #   [ { device = "/dev/disk/by-uuid/d785e4a0-ee6e-405c-95d0-5a3a534bd98e"; }
  #   ];

  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp6s0.useDHCP = lib.mkDefault true;
}
