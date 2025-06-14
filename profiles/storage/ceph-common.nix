{
  services.ceph = {
    enable = true;
    global = {
      fsid = "4b687c5c-5a20-4a77-8774-487989fd0bc7"; # Замените на ваш UUID!
      public_network = "192.168.1.0/24";
      auth_cluster_required = "none";
      auth_service_required = "none";
      auth_client_required = "none";
      mon_initial_members = "q1, i7, j4";  # Все мониторы
      mon_host = "192.168.1.18, 192.168.1.15, 192.168.1.16";  # IP всех мониторов
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
}