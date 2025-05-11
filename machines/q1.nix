{ lib, ... }:
{
  
  networking.hostName = "q1"; # Define your hostname.
  networking.hostId = "9c60a626";

  imports = [ 
    ../profiles/boot/systemd-boot.nix
    ../profiles/video/nvidia-simple.nix
    ../profiles/network/ntp-server-ru.nix
    ../profiles/common.nix 
    # ../profiles/k3s.nix 
  ];

  systemd.network = {
    links."10-eth0".matchConfig.MACAddress = 
      lib.concatStringsSep " " [  # Объединение через пробел
        "20:7c:14:f4:21:34"   # Физический интерфейс
      ];
    
    networks = {
      "30-br0" = {
        address = [ 
          "192.168.1.18/24" 
          # Для IPv6 (если нужно):
          # "2001:db8::a7/64"
        ];
      };
    };    
  };

  # services.ntp-ru.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c39c8bb9-7bcc-4259-a79b-53299fa48238";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0307-F9E8";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  # swapDevices =
  #   [ { device = "/dev/disk/by-uuid/d785e4a0-ee6e-405c-95d0-5a3a534bd98e"; }
  #   ];

  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp6s0.useDHCP = lib.mkDefault true;
}

