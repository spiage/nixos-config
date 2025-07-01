{ pkgs, ... }:
{
  services.ceph = {
    enable = true;
    global = {
      fsid = "8ed79199-4c23-4a21-8591-5016a822ba40"; # запустить uuidgen
      publicNetwork = "192.168.1.0/24";
      authClusterRequired = "none";
      authServiceRequired = "none";
      authClientRequired = "none";
      monInitialMembers = "q1, i7, j4";
      monHost = "192.168.1.18, 192.168.1.15, 192.168.1.16";

    };
    # Общие настройки OSD
    osd.extraConfig = {
      "osd pool default size" = "2";
      "osd pool default min size" = "1";
    };
  };

  # Общие системные настройки
  boot.kernelModules = ["ceph"];  # Для CephFS
  users.users.ceph = {
    isSystemUser = true;
    group = "ceph";
    extraGroups = ["disk"];
  };
  users.groups.ceph = {};

  environment.systemPackages = with pkgs; [
    ceph # Основные утилиты
    ceph-client # Только клиентские инструменты (опционально)
    xfsprogs # Для работы с XFS (если будете форматировать RBD)
  ];

}