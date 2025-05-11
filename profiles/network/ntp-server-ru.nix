{ config, lib, ... }:
{
  # Отключаем systemd-timesyncd
  systemd.services.systemd-timesyncd.enable = lib.mkForce false;
  # Полностью отключаем взаимодействие с RTC
  services.chrony.enableRTCTrimming = lib.mkForce false;
  time.hardwareClockInLocalTime = lib.mkForce false;
  
  # Включаем и настраиваем chrony (более современная альтернатива ntpd)
  services.chrony = {
    enable = true;
    servers = [
      # Российские пулы
      "0.ru.pool.ntp.org"
      "1.ru.pool.ntp.org"
      "2.ru.pool.ntp.org"
      "3.ru.pool.ntp.org"
      
      # Европейские серверы с низкой задержкой
      "ntp1.vniiftri.ru"    # Москва, ВНИИФТРИ
      "ntp2.vniiftri.ru"
      "ntp0.ntp-servers.net"
      "ntp1.ntp-servers.net"
    ];
    extraConfig = ''
      # Разрешаем подключения из локальной сети
      allow 192.168.0.0/16
      
      # Настройки для Москвы (UTC+3)
      leapsectz right/Europe/Moscow
      makestep 1.0 3
      driftfile /var/lib/chrony/drift
      logdir /var/log/chrony
    '';
  };

  # Открываем порт NTP в firewall
  networking.firewall.allowedUDPPorts = lib.mkMerge [
    (lib.mkAfter [ 123 ])  # NTP
  ];
}