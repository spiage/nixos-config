{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ../profiles/common.nix
    ../profiles/laptop.nix
    ../profiles/boot/systemd-boot.nix
    ../profiles/desktop/fonts.nix
    ../profiles/desktop/plasma6.nix
    ../profiles/desktop/printing.nix
    ../profiles/desktop/pipewire.nix
    ../profiles/desktop/packages.nix
    ../profiles/hardware/graphics.nix
  ];

  networking.hostName = "z1";

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5a458e59-b6cc-4b99-bf5b-17e4ff9fa464";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/DD76-87F5";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/1f3153b7-1c56-42ea-8938-50a5fbb9ed85"; }
  ];

  # Intel GPU
  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = lib.mkForce false;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # Plasma 6 + Wayland
  services.xserver.videoDrivers = [ "modesetting" ];

  # Пользователи определяются в common.nix

  system.stateVersion = lib.mkForce "24.11";
}
