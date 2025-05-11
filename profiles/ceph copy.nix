{ config, lib, pkgs, ... }: {
  # Основные настройки Ceph
  services.ceph = {
    enable = true;
    global = {
      fsid = "a7f3e5d9-1234-5678-90ab-cdef01234567"; # Замените на свой FSID
      mon_initial_members = "a7,i9,i7";
      mon_host = "192.168.1.2,192.168.1.201,192.168.1.15";
      public_network = "192.168.1.0/24";
      cluster_network = "192.168.1.0/24";
    };

    mon = {
      enable = true;
      daemons = [ "a7" "i9" "i7" ];
    };

    osd = {
      enable = true;
      daemons = [ "a7" "i9" "i7" ];
      extraConfig = {
        "osd journal size" = "10000";
        "osd pool default size" = "2"; # Репликация между 2 узлами
        "osd pool default min size" = "1";
      };
    };

    mgr = {
      enable = true;
      daemons = [ "a7" "i9" ];
    };
  };
  services.ceph = {
    enable = true;
    global = {
      inherit clusterName fsid;
      monInitialMembers = lib.concatStringsSep "," monInitialMembers; # camelCase!
      monHost = lib.concatStringsSep "," monHost; # camelCase!
      publicNetwork = publicNetwork;
      authClusterRequired = "cephx";
      authServiceRequired = "cephx";
      authClientRequired = "cephx";
    };

    mon = {
      enable = true;
      daemons = monInitialMembers; 
    };
  };
  # Автоматизация OSD с файлами-образами
  systemd.services = let
    osdImage = "/persist/osd/ceph-osd-${config.networking.hostName}.img";
  in {
    ceph-osd-prepare = {
      description = "Prepare Ceph OSD directory and image";
      before = [ "ceph-osd@*.service" ];
      requiredBy = [ "ceph-osd@*.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "ceph-osd-prepare" ''
          mkdir -p /persist/osd
          if ! [[ -f ${osdImage} ]]; then
            ${pkgs.coreutils}/bin/dd if=/dev/zero of=${osdImage} \
              bs=1G count=100 status=progress
          fi
          ${pkgs.utillinux}/bin/losetup /dev/loop0 ${osdImage} || true
        '';
        ExecStop = "${pkgs.utillinux}/bin/losetup -d /dev/loop0";
      };
    };

    ceph-osd-preactivate = {
      description = "Prepare OSD for activation";
      requires = [ "ceph-osd-prepare.service" ];
      after = [ "ceph-osd-prepare.service" ];
      before = [ "ceph-osd@*.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.ceph}/bin/ceph-volume lvm prepare --data /dev/loop0 --no-systemd";
      };
    };
  };

  # Интеграция с Libvirt
  services.libvirt = {
    enable = true;
    secrets = {
      "ceph-vms" = {
        uuid = "d5f5a145-5a3d-4a7b-8b8e-1234567890ab";
        value = builtins.readFile "/etc/ceph/ceph.client.libvirt.keyring";
      };
    };
    storagePools = [{
      name = "ceph-vms";
      type = "rbd";
      autostart = true;
      extraConfig = ''
        <source>
          <name>vms</name>
          <host name='a7' port='6789'/>
          <host name='i9' port='6789'/>
          <host name='i7' port='6789'/>
          <auth username='libvirt' type='ceph'>
            <secret uuid='d5f5a145-5a3d-4a7b-8b8e-1234567890ab'/>
          </auth>
        </source>
      '';
    }];
  };

  # Настройки сети
  networking.firewall = {
    allowedTCPPorts = [ 
      6789 # Мониторы
      6800-7300 # OSD
    ];
    allowedUDPPorts = [ 6789 ];
  };
}