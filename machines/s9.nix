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
  ];

  networking.hostName = "s9";

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/05550c8a-75d7-494a-bfa9-fcaaef1cf93c";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/405A-6EDC";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/f58f04a4-59f3-4a57-8fe2-cb87cbbbd7e1";
    fsType = "btrfs";
  };

  swapDevices = [ ];

  # Plasma 6 + Wayland
  services.xserver.videoDrivers = [ "modesetting" ];

  # Пользователи
  users.users.taka = {
    isNormalUser = true;
    description = "taka";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "audio" "incus-admin" "kvm" "libvirtd" "vboxusers" "video" ];
  };

  system.stateVersion = lib.mkForce "23.05";
}
