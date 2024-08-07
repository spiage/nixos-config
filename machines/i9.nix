{
  networking.hostName = "i9"; # Define your hostname.

  imports = [ 
    ../profiles/boot/systemd-boot.nix
    ../profiles/common.nix 
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8cdd3d84-92f6-4fdf-b22a-c802f889531c";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/8cdd3d84-92f6-4fdf-b22a-c802f889531c";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/8cdd3d84-92f6-4fdf-b22a-c802f889531c";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0E31-C16B";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  # swapDevices =
  #   [ { device = "/dev/disk/by-uuid/3e86da97-ede3-4c0c-9dbf-9cdbc8550b44"; }
  #   ];

  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;
  # networking = {
  #   bridges = {
  #     "lan".interfaces = [ "enp3s0" ]; #host.lan.devices;
  #     #[ "enp3s0" "enp8s0" "enp9s0" "enp10s0" "enp11s0" ];
  #     #"wan".interfaces = [ "enp3s0" ];
  #   };
  #   interfaces = {
  #     lan.ipv4.addresses = [
  #       {
  #         address = "192.168.1.19"; #"${host.lan.ip}";
  #         prefixLength = 16; #host.lan.prefix;
  #       }
  #     ];
  #     # wan = {
  #     #   useDHCP = false;
  #     #   #   macAddress = host.wan.mac";
  #     # };
  #   };
  # };
  networking = {
    bridges.br0.interfaces = [ "enp3s0" ];
    useDHCP = false;
    interfaces.enp3s0.useDHCP = false;
    interfaces.br0.useDHCP = true;
  };
}