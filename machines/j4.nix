{
  networking.hostName = "j4"; # Define your hostname.

  imports = [ 
    ../profiles/boot/systemd-boot.nix
    ../profiles/common.nix 
  ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "pata_jmicron" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/eebf8ebb-2f59-43c9-bbca-495bd11cc359";
      fsType = "xfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0BE9-0BB1";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/0a3e5298-1553-4efb-ba47-3bc330d803b0"; }
    ];

  fileSystems."/srv/Backups" =
    { device = "/dev/disk/by-uuid/e1300de0-05f9-4ca4-9640-a1976be21f49";
      fsType = "btrfs";
      options = [ "subvol=Backups" "noatime" ]; #compress=zstd" "noatime" ];
    };

  fileSystems."/srv/Shares/Public" =
    { device = "/dev/disk/by-uuid/e1300de0-05f9-4ca4-9640-a1976be21f49";
      fsType = "btrfs";
      options = [ "subvol=Shares/Public" "noatime" ]; # "compress=zstd" "noatime" ];
    };

  fileSystems."/srv/Shares/Private" =
    { device = "/dev/disk/by-uuid/e1300de0-05f9-4ca4-9640-a1976be21f49";
      fsType = "btrfs";
      options = [ "subvol=Shares/Private" "noatime" ]; # "compress=zstd" "noatime" ];
    };

  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user 
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.1. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      public = {
        path = "/srv/Shares/Public";
        browseable = "yes";
        writable = "yes";
        public = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "spiage";
        #"force group" = "groupname";
      };
      private = {
        path = "/srv/Shares/Private";
        browseable = "yes";
        writable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0744";
        "directory mask" = "0755";
        "force user" = "spiage";
        #"force group" = "groupname";
      };
      public1 = {
        path = "/home/spiage/p1";
        browseable = "yes";
        writable = "yes";
        public = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "spiage";
        #"force group" = "groupname";
      };

    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

}