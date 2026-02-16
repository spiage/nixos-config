{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.networking.dns-dhcp-server;
in
{
  options.profiles.networking.dns-dhcp-server = {
    enable = lib.mkEnableOption "Enable combined DNS and DHCP server for homelab";

    # DHCP options
    interface = lib.mkOption {
      type = lib.types.str;
      default = "br0";
      description = "Interface to serve on";
    };
    rangeStart = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.100";
      description = "Start of DHCP range";
    };
    rangeEnd = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.229";
      description = "End of DHCP range";
    };
    leaseTime = lib.mkOption {
      type = lib.types.str;
      default = "24h";
      description = "DHCP lease time";
    };
    gateway = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.1";
      description = "Default gateway";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "k8s.local";
      description = "Local domain name";
    };
    staticHosts = lib.mkOption {
      type =
        with lib.types;
        listOf (submodule {
          options = {
            mac = lib.mkOption { type = str; };
            ip = lib.mkOption { type = str; };
            name = lib.mkOption { type = str; };
            description = lib.mkOption {
              type = str;
              default = "";
            };
          };
        });
      default = [ ];
      description = "Static host assignments";
    };

    # DNS options
    forwarders = lib.mkOption {
      type = with lib.types; listOf str;
      default = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      description = "Upstream DNS servers";
    };
  };

  config = lib.mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;
      settings = {
        # Общие настройки
        bind-interfaces = true;
        domain-needed = true;
        bogus-priv = true;
        expand-hosts = true;
        # local = "/${cfg.domain}/";

        # DHCP-настройки
        interface = cfg.interface;
        dhcp-range = "${cfg.rangeStart},${cfg.rangeEnd},${cfg.leaseTime}";
        dhcp-option = [
          "option:dns-server,192.168.1.18" # IP вашего DNS-сервера
          "option:domain-search,k8s.local" # Домен для поиска
          "option:router,${cfg.gateway}"
          # "option:dns-server,${cfg.gateway}" # Используем роутер как DNS
        ];
        dhcp-host = map (
          host:
          "${host.mac},${host.ip},${host.name},infinite"
          + (if host.description != "" then ",set:${host.description}" else "")
        ) cfg.staticHosts;

        # DNS-настройки
        port = 53;
        no-resolv = true;
        server = cfg.forwarders;
        address = map (host: "/${host.name}.${cfg.domain}/${host.ip}") cfg.staticHosts;
      };
    };

    # Настройки firewall
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [
      53
      67
      68
    ];

    # Дополнительные параметры
    systemd.services.dnsmasq.serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = "5s";
    };

    # Создаем каталог для lease-файлов
    systemd.tmpfiles.rules = [
      "d /var/lib/dnsmasq 0755 dnsmasq dnsmasq - -"
    ];
  };
}
