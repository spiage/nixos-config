{ config, pkgs, lib, ... }:
{

  networking.hostName = "i9"; # Define your hostname.
  networking.hostId = "2ae0c11a";

  imports = [ 
    ../profiles/boot/systemd-boot.nix
    ../profiles/common.nix 
  ];
  systemd.network = {
    links."10-eth0".matchConfig.MACAddress = 
      lib.concatStringsSep " " [  # Объединение через пробел
        "2c:f0:5d:29:f6:01"   # Физический интерфейс
      ];
    
    networks = {
      "30-br0" = {
        address = [ 
          "192.168.1.201/16" 
          # Для IPv6 (если нужно):
          # "2001:db8::a7/64"
        ];
        networkConfig = {
          DNS = "192.168.1.18";  # DNS-сервер q1
          Gateway = "192.168.1.1";
        };
      };
    };    
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  # boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    kernelParams = [ "nvidia.NVreg_EnableGpuFirmware=1" ];
    kernelModules = [ "nvidia_uvm" ];
  };

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = true;

      package = config.boot.kernelPackages.nvidiaPackages.beta;

      #  package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      #    version = "575.51.02";
      #    sha256_64bit = "sha256-XZ0N8ISmoAC8p28DrGHk/YN1rJsInJ2dZNL8O+Tuaa0=";
      #    openSha256 = "sha256-6n9mVkEL39wJj5FB1HBml7TTJhNAhS/j5hqpNGFQE4w=";
      #    settingsSha256 = "sha256-NQg+QDm9Gt+5bapbUO96UFsPnz1hG1dtEwT/g/vKHkw=";
      #    usePersistenced = false;
      #  };
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
  environment.systemPackages = with pkgs; [
    ollama
    (pkgs.gpufetch.override { cudaSupport = true; })
    nvtopPackages.nvidia
    gwe
    vulkan-tools
    zenith-nvidia
    nvitop
    #      nvidia-vaapi-driver
  ];

  environment.shellAliases = {
    gwe = "setsid gwe";
    gputop = "nvidia-smi -l 1";
    gpu_temp = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits";
    nvidia-settings = "setsid nvidia-settings";
  };

  systemd.services.nvidia-poweroff = rec {
    enable = false;
    description = "Unload nvidia modules from kernel";
    documentation = [ "man:modprobe(8)" ];

    unitConfig.DefaultDependencies = "no";

    after = [ "umount.target" ];
    before = wantedBy;
    wantedBy = [
      "shutdown.target"
      "final.target"
    ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "-${pkgs.kmod}/bin/rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia";
    };
  };

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
    { device = "/dev/disk/by-uuid/E1BF-23DD";
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

  services.ollama = {
    enable = true;
    package = (pkgs.ollama.override { acceleration = "cuda"; });
    acceleration = "cuda";
    environmentVariables = {
      #     HIP_VISIBLE_DEVICES = "0,1";
      #     OLLAMA_LLM_LIBRARY = "cpu";
      OLLAMA_HOST = "http://192.168.1.201:11434";
    };
    # home = "/куда";
    host = "192.168.1.201";
    openFirewall = true;

  };

  services.open-webui = {
    enable = true;
    port = 8081;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://192.168.1.201:11434";
      WEBUI_AUTH = "False";
    };
    host = "192.168.1.201";
    openFirewall = true;
  };
}