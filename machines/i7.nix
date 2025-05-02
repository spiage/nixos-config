{ config, ...}:
{
  
  networking.hostName = "i7"; # Define your hostname.
  networking.hostId = "52a8a4b0";

  imports = [ 
    ../profiles/boot/grub2.nix 
    ../profiles/video/nvidia-simple.nix
    ../profiles/common.nix 
    ../profiles/k3s.nix 
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/db517bd8-d60d-4179-8c58-f3fb8a16edad";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/db517bd8-d60d-4179-8c58-f3fb8a16edad";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/db517bd8-d60d-4179-8c58-f3fb8a16edad";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" ];
    };

  # swapDevices =
  #   [ { device = "/dev/disk/by-uuid/fb23503e-b052-4737-bed8-38c14ef5ef47"; }
  #   ];

  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp12s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp8s0.useDHCP = lib.mkDefault true;
}