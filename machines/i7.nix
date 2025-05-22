{ config, lib, ...}:
{
  
  networking.hostName = "i7"; # Define your hostname.
  networking.hostId = "52a8a4b0";
  # # Физический интерфейс (enp12s0) → eth0
  # services.udev.extraRules = ''
  #   SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="a8:42:a1:ff:eb:e3", NAME="eth0"
  #   SYMLINK+="enp12s0-physical"
  # '';
  # systemd.network.networks."main-eth" = {
  #   matchConfig.Name = "eth0";
  #   address = ["192.168.1.15/24"];
  #   gateway = ["192.168.1.1"];
  #   dns = ["192.168.1.1"];
  #   networkConfig = {
  #     DHCP = "no";
  #     Domains = "k8s.local";
  #   };
  # };
  # # networking.useDHCP = false;
  
  # networking = {
  #   usePredictableInterfaceNames = false; 
  #   bridges.br0.interfaces = [ "eth0" ];
  #   interfaces.eth0.useDHCP = false;
  #   interfaces.br0.useDHCP = true;
  # };
  # networking.dhcpcd.extraConfig = "noipv6rs"; 
  # defaultGateway = "10.0.0.1";
  # bridges.br0.interfaces = ["eno1"];
  # interfaces.br0 = {
  #   useDHCP = false;
  #   ipv4.addresses = [{
  #     "address" = "10.0.0.5";
  #     "prefixLength" = 24;
  #   }];
  # };
  imports = [ 
    ../profiles/boot/grub2.nix 
    ../profiles/video/nvidia-simple.nix
    ../profiles/common.nix 
    ../profiles/k3s.nix 
    # ../profiles/libvirt-vms.nix 
  ];
  systemd.network = {
    links."10-eth0".matchConfig.MACAddress = 
      lib.concatStringsSep " " [  # Объединение через пробел
        "a8:42:a1:ff:eb:e3"   # Физический интерфейс
      ];
    
    networks = {
      "30-br0" = {
        address = [ 
          "192.168.1.15/16" 
          # Для IPv6 (если нужно):
          # "2001:db8::a7/64"
        ];
      };
    };    
  };

  # virtualMachines = {
  #   "webserver" = {
  #     user = "spiage";
  #     sshKey = ./keys/webserver-key.pub;
  #     cpus = 3;
  #     memory = 5120; # 5GB
  #     diskSize = 7;
  #   };

  #   "database" = {
  #     user = "spiage";
  #     sshKey = ./keys/db-key.pub;
  #     cpus = 2;
  #     memory = 4096;
  #     diskSize = 15;
  #   };
  # };

  # vxlanConfig = {
  #   localIP = "192.168.1.15";       # Физический IP a7
  #   remoteIPs = [ "192.168.1.2" "192.168.1.18" ];  # IP i7 и q1
  #   vxlanIP = "10.10.10.1";        # VXLAN-адрес a7
  #   physicalInterface = "br0";  # Укажите ваш интерфейс (eno1, enp1s0 и т.д.)
  # };

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