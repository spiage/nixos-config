{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.ceph = {
    enable = true;
    global = {
      fsid = "a7f3e5d9-1234-5678-90ab-cdef01234567"; # Одинаковый для всех узлов!
      mon_initial_members = "a7,i9,i7"; # Список всех мониторов
      mon_host = "192.168.1.2,192.168.1.201,192.168.1.15"; # IP всех узлов
    };

    mon.daemons = [ "a7" ]; # Уникальный ID монитора для текущего узла
    osd.daemons = [ "a7" ]; # Уникальный ID OSD
    mgr.daemons = [ "a7" ]; # Уникальный ID менеджера (опционально)
  };
}
