# vxlan.nix
{ config, lib, pkgs, ... }:

{
  systemd.network = {
    netdevs = {
      # Конфигурация VXLAN
      "40-vxlan0" = {
        netdevConfig = {
          Name = "vxlan0";
          Kind = "vxlan";
        };
        vxlanConfig = {
          VNI = 100;
          Group = "239.1.1.1";
          DestinationPort = 4789;
          TTL = 5;
          # UnderlyingDevice = "eth0";
        };
      };

      # Явное определение бриджа br0 (если ещё не определено)
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
      # Привязка VXLAN к бриджу
      "40-vxlan0" = {
        matchConfig.Name = "vxlan0";
        bridge = [ "br0" ];
        linkConfig.RequiredForOnline = "no";
      };

    };
  };

  # Настройки фаервола
  networking.firewall.allowedUDPPorts = [ 4789 ];

  # Гарантия загрузки модуля ядра
  boot.kernelModules = [ "vxlan" ];

  # Корректные systemd зависимости
  systemd.services.systemd-networkd = {
    after = [ 
      "network-pre.target" 
      "systemd-networkd-wait-online.service" 
    ];
    requires = [ "network-pre.target" ];
  };
}