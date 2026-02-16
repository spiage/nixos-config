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
    ../profiles/common.nix
    # ../profiles/k3s.nix
  ];

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
      # {
      #   mac = "2c:f0:5d:29:f6:01";
      #   ip = "192.168.1.201";
      #   name = "i9";
      #   description = "core";
      # }
      {
        mac = "a8:42:a1:ff:eb:e3";
        ip = "192.168.1.15";
        name = "i7";
        description = "core";
      }
      {
        mac = "2c:f0:5d:29:f6:01";
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
        mac = "52:54:00:80:c0:93";
        ip = "192.168.1.102";
        name = "n1";
        description = "vm";
      }
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

}
