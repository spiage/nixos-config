{ config, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName != "q1") {
    # Отключаем chrony на клиентах
    services.chrony.enable = false;

    # Настраиваем systemd-timesyncd
    services.timesyncd = {
      enable = true;
      servers = [ "192.168.1.18" ]; # IP q1
      extraConfig = ''
        # Точность синхронизации для локальной сети
        PollIntervalMinSec=16
        PollIntervalMaxSec=32
        RootDistanceMaxSec=0.1
      '';
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
