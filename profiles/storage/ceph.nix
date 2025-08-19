{ config, pkgs, ... }:
{
  # Включить поддержку Ceph и необходимые модули
  boot.supportedFilesystems = [ "ceph" ];
  boot.kernelModules = [ "rbd" ];

  # Открыть порты в firewall
  networking.firewall = {
    allowedTCPPorts = [
      6789 # Мониторы Ceph
      {
        from = 6800;
        to = 7300;
      } # OSD
    ];
    allowedUDPPorts = [ 6789 ];
  };

  # Установка необходимых пакетов
  environment.systemPackages = with pkgs; [
    ceph
    rbd-nbd
    qemu
  ];

  services.ceph.global.fsid = "edf93b5d-3134-4a52-b43f-44048c956b20";
  services.ceph = {
    enable = true;
    global = {
      # fsid = "a7f3e5d9-1234-5678-90ab-cdef01234567"; # Генерировать командой `uuidgen` для каждого хоста
      monInitialMembers = "a7,i9,i7";
      monHost = "192.168.1.2,192.168.1.201,192.168.1.15";
    };

    mon = {
      enable = true;
      daemonId = config.networking.hostName; # Уникальный ID для каждого монитора
    };

    osd = {
      enable = true;
      daemonId = config.networking.hostName;
    };
  };

}
