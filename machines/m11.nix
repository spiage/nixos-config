{ config, pkgs, inputs, lib, ... }:

{

  imports = [
    inputs.nixos-hardware.nixosModules.apple-macbook-air-7
    ../profiles/homelab.nix
    ../profiles/laptop.nix
    ../profiles/boot/systemd-boot.nix
    ../profiles/network/dns-client.nix
    ../profiles/desktop/fonts.nix
    ../profiles/desktop/plasma6.nix
    ../profiles/desktop/printing.nix
    ../profiles/desktop/pipewire.nix
    ../profiles/desktop/packages.nix
    ../profiles/hardware/graphics.nix
  ];
  hardware.facetimehd.enable = lib.mkForce false;

  networking.hostName = "m11";

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.blacklistedKernelModules = [ "b43" "bcma" "ssb" ];
  boot.kernelModules = [ "kvm-intel" "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  nixpkgs.config.permittedInsecurePackages = [ "broadcom-sta-6.30.223.271-59-7.0.10" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b8ab283a-9e38-47a8-806a-5ef116b5972e";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B844-84D1";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/08b0e90a-28dc-4ff6-aadf-3499f388a791"; }
    ];

  system.stateVersion = lib.mkForce "25.11";

}
