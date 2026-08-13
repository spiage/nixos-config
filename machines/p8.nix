{ config, pkgs, lib, inputs, ... }:

{

  imports = [
    # inputs.nixos-hardware.nixosModules.common-cpu-amd
    # inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    # inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../profiles/boot/systemd-boot.nix
    ../profiles/common.nix
    ../profiles/laptop.nix
    ../profiles/network/dns-client.nix
    ../profiles/desktop/fonts.nix
    ../profiles/desktop/plasma6.nix
    ../profiles/desktop/printing.nix
    ../profiles/desktop/pipewire.nix
    ../profiles/desktop/packages.nix
    ../profiles/hardware/graphics.nix
  ];

  systemd.network.enable = lib.mkForce false;
#  systemd.network = {
#    links."10-eth0".matchConfig.MACAddress = lib.concatStringsSep " " [
#      # Объединение через пробел
#      "00:e0:4c:5d:8f:25" # Физический интерфейс
#    ];
#
#    networks = {
#      "30-br0" = {
#        address = [
#          "192.168.1.109/16"
#          # Для IPv6 (если нужно):
#          # "2001:db8::a7/64"
#        ];
#        networkConfig = {
#          DNS = "192.168.1.18"; # DNS-сервер q1
#          Gateway = "192.168.1.1";
#        };
#      };
#    };
#  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "i915.force_probe=46d2"
    "fbcon=rotate:1"
    "video=DSI-1:panel_orientation=right_side_up"
  ];

  hardware.sensor.iio.enable = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4fb8a3c8-38e2-422d-ba0d-a2003471387c";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8172-E525";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking.hostName = "p8"; # Define your hostname.
  networking.networkmanager.enable = lib.mkForce true;

  virtualisation.libvirtd.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
  ];

  system.stateVersion = lib.mkForce "26.05"; # Did you read the comment?

}
