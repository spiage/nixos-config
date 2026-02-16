{ config, lib, ... }:
{

  networking.hostName = "n1"; # Define your hostname.
  networking.hostId = "1becbae6"; # head -c4 /dev/urandom | od -A none -t x4
  imports = [
    ../profiles/boot/systemd-boot.nix
    ../profiles/network/dns-client.nix
    ../profiles/common.nix
  ];
  systemd.network = {
    links."10-eth0".matchConfig.MACAddress = lib.concatStringsSep " " [
      "52:54:00:80:c0:93" # Физический интерфейс
    ];

    networks = {
      "30-br0" = {
        address = [
          "192.168.1.102/16"
          # Для IPv6 (если нужно):
          # "2001:db8::a7/64"
        ];
        networkConfig = {
          DNS = "192.168.1.18"; # DNS-сервер q1
          Gateway = "192.168.1.1";
        };
      };
    };
  };

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "sr_mod" "virtio_pci" "virtio_blk" "virtio_scsi" "virtio_net" "virtio_balloon" "virtio_console" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.supportedFilesystems = [
    "ntfs"
    "btrfs"
    "ext4"
    "xfs"
    "zfs"
  ];
  boot.zfs.extraPools = [ "store_pool" ];
  services.zfs.autoScrub.enable = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/09acbb27-663a-412d-939d-2c86130e634b";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/AC61-4613";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

}
