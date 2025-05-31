# modules/vxlan.nix
{ config, lib, pkgs, ... }:

let
  homeDomainName = "k8s.local";
  vxlanId = 42;
  vxlanPort = 4789;
  vxlanNetwork = "10.0.0.0/16";
in {
  options.vxlan.enable = lib.mkEnableOption "Enable VXLAN overlay network";

  config = lib.mkIf config.vxlan.enable {
    # Настройка VXLAN и моста
    systemd.network = {
      netdevs."30-vxlan" = {
        netdevConfig = {
          Name = "vxlan0";
          Kind = "vxlan";
        };
        vxlanConfig = {
          VNI = vxlanId;
          Group = "239.1.1.1";
          DestinationPort = vxlanPort;
          GroupPolicyExtension = true;
        };
      };

      networks."40-br-vxlan" = {
        matchConfig.Name = "br-vxlan";
        bridge = ["vxlan0"];
        networkConfig = {
          Bridge = true;
          IPMasquerade = "both";
          LLMNR = true;
          MulticastDNS = true;
        };
        addresses = [{
          addressConfig.Address = 
            let 
              hostOctet = lib.last (lib.splitString "." config.networking.hostName);
            in "10.0.0.${hostOctet}/16";
        }];
      };
    };

    # Настройка libvirt для использования моста
    environment.etc."libvirt/qemu/networks/vxlan.xml" = {
      text = ''
        <network>
          <name>vxlan</name>
          <forward mode="bridge"/>
          <bridge name="br-vxlan"/>
        </network>
      '';
      mode = "0644";
    };

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        # package = pkgs.qemu_kvm; # есть в common
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    networking.firewall.allowedUDPPorts = [vxlanPort];
    boot.kernelModules = [ "vxlan" "bridge" ];
    environment.systemPackages = [ pkgs.bridge-utils pkgs.tcpdump ];
  };
}