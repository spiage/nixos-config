{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.networking.dns-server;
  dhcpCfg = config.profiles.networking.dhcp-server;
  domain = dhcpCfg.domain;
in
{
  options.profiles.networking.dns-server = {
    enable = lib.mkEnableOption "Enable DNS server for homelab";
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
        # Основные настройки
        port = 53;
        domain-needed = true;
        bogus-priv = true;
        no-resolv = true;
        server = cfg.forwarders;
        local = "/${domain}/";
        expand-hosts = true;

        # Статические записи
        address = map (host: "/${host.name}.${domain}/${host.ip}") dhcpCfg.staticHosts;
      };
    };

    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
