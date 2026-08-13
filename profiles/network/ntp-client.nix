{ config, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName != "q1") {
    # Отключаем chrony на клиентах
    services.chrony.enable = false;

    # Настраиваем systemd-timesyncd
    services.timesyncd = {
      enable = true;
      servers = [ "192.168.1.18" "ntp1.vniiftri.ru" ]; # IP q1
      #  Failed assertions:
      #  - The option definition `services.timesyncd.extraConfig' in `/nix/store/3mj6g2mq6giy0841lmy219h8iahf00xn-source/profiles/network/ntp-client.nix' no longer has any effect; please remove it.
      #  Use services.timesyncd.settings.Time instead.
      # extraConfig = ''
      #   # Точность синхронизации для локальной сети
      #   PollIntervalMinSec=16
      #   PollIntervalMaxSec=32
      #   RootDistanceMaxSec=0.1
      # '';
    };

    systemd.services.systemd-timesyncd = {
      serviceConfig = lib.mkMerge [
        (lib.mkOverride 10 {
          # Явные зависимости
          Requires = [ "network-online.target" ];
          After = [
            "network-online.target"
            "systemd-networkd-wait-online.service"
          ];
        })
      ];
    };

    # Активируем target для сетевой готовности
    systemd.targets.network-online.enable = true;
  };

}
