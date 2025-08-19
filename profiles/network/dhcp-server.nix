{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.networking.dhcp-server;
in
{
  options.profiles.networking.dhcp-server = {
    enable = lib.mkEnableOption "Enable DHCP server for homelab";
    interface = lib.mkOption {
      type = lib.types.str;
      default = "br0";
      description = "Interface to serve DHCP on";
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
    dnsServer = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.18";
      description = "Primary DNS server (q1)";
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
  };

  config = lib.mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;
      settings = {
        # Отключаем DNS-сервер
        # port = 0;

        # Настройки DHCP
        interface = cfg.interface;
        bind-interfaces = true;
        dhcp-range = "${cfg.rangeStart},${cfg.rangeEnd},${cfg.leaseTime}";
        dhcp-option = [
          "option:router,${cfg.gateway}"
          "option:dns-server,${cfg.dnsServer}"
        ];
        dhcp-host = map (
          host:
          "${host.mac},${host.ip},${host.name},infinite"
          + (if host.description != "" then ",set:${host.description}" else "")
        ) cfg.staticHosts;
      };
    };

    networking.firewall.allowedUDPPorts = [
      67
      68
    ];
  };
}
