{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{

  networking.hostName = "i9"; # Define your hostname.
  networking.hostId = "2ae0c11a";

  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.vscode-server.nixosModules.default
    ../profiles/boot/systemd-boot.nix
    ../profiles/network/dns-client.nix
    ../profiles/common.nix
  ];
  systemd.network = {
    links."10-eth0".matchConfig.MACAddress = lib.concatStringsSep " " [
      # Объединение через пробел
      "9c:6b:00:aa:7e:38" # Физический интерфейс
    ];

    networks = {
      "30-br0" = {
        address = [
          "192.168.1.201/16"
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

  services.xserver.videoDrivers = [ "nvidia" ];
  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "uas"
    "usbhid"
    "sd_mod"
  ];
  boot.supportedFilesystems = [
    "ntfs"
    "btrfs"
    "ext4"
    "xfs"
    "zfs"
  ];
  boot.extraModulePackages = [ ];
  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    kernelParams = [
      "nvidia.NVreg_EnableGpuFirmware=1"
      "mitigations=off"
      "preempt=full"
      "nowatchdog"
      "kernel.nmi_watchdog=0"
    ];
    kernelModules = [
      "nvidia_uvm"
      "kvm-amd"
      "bfq"
      "mt7921e"
      "k10temp"
    ];
  };

  hardware = {
    nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = true;

      # package = config.boot.kernelPackages.nvidiaPackages.beta;

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

  programs.virt-manager.enable = true;

  programs.nix-ld.enable = true;

  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

    virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
      # declare containers
    };
    # oci-containers = {
    #   ## use podman as default container engine
    #   backend = "podman";
    # };
  };
  nixpkgs.config = {
    # https://nixos.org/manual/nixpkgs/unstable/#cuda
    allowUnfreePredicate = pkgs._cuda.lib.allowUnfreeCudaPredicate;
    # cudaCapabilities = [ "8.7" ]; # for my RTX 3090 # https://en.wikipedia.org/wiki/CUDA#GPUs_supported
    #    error: cudaPackages_12_8.backendStdenv has failed assertions:
    #    - Requested Jetson CUDA capabilities (["8.7"]) require hostPlatform (x86_64-linux) to be aarch64-linux
    #    - Requested pre-Thor (10.1) Jetson CUDA capabilities (["8.7"]) require computed NVIDIA hostRedistSystem (linux-x86_64) to be linux-aarch64
    cudaForwardCompat = true;
    cudaSupport = true;
  };
  nixpkgs.overlays = [ (final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [ (pyfinal: pyprev: {
      rapidocr-onnxruntime = pyprev.rapidocr-onnxruntime.overridePythonAttrs (oldAttrs: {
        doCheck = false;
        doInstallCheck = false;
        dontCheck = true;
      });
#      langchain-community = pyprev.langchain-community.overridePythonAttrs (oldAttrs: {
#        doCheck = false;
#        doInstallCheck = false;
#        dontCheck = true;
#      });
    }) ];
  }) ];

  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps: with ps; [ lxml ]))
    sqlite
    dive
    podman-compose
    distrobox
    ollama
    (pkgs.gpufetch.override { cudaSupport = true; })
    nvtopPackages.nvidia
#    gwe
    vulkan-tools
    zenith-nvidia
    nvitop
    uv
    #      nvidia-vaapi-driver
    # guestfs-tools # Extra tools for accessing and modifying virtual machine disk images
    libguestfs-with-appliance
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

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8cdd3d84-92f6-4fdf-b22a-c802f889531c";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/8cdd3d84-92f6-4fdf-b22a-c802f889531c";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/8cdd3d84-92f6-4fdf-b22a-c802f889531c";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E1BF-23DD";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  networking = {
    bridges.br0.interfaces = [ "enp3s0" ];
    useDHCP = false;
    interfaces.enp3s0.useDHCP = false;
    interfaces.br0.useDHCP = true;
  };

  services.ollama = {
    enable = true;
    # package = pkgs.ollama.override { acceleration = "cuda"; });
    # acceleration = "cuda";
#        - The option definition `services.ollama.acceleration' in `/nix/store/q6cnki835li5hf95py9wi5zfx68mka21-source/machines/i9.nix' no longer has any effect; please remove it.
#        Set `services.ollama.package` to one of `pkgs.ollama[,-vulkan,-rocm,-cuda,-cpu]` instead.
    package = pkgs.ollama-cuda;
    environmentVariables = {
      #     HIP_VISIBLE_DEVICES = "0,1";
      #     OLLAMA_LLM_LIBRARY = "cpu";
      OLLAMA_HOST = "http://192.168.1.201:11434";
    };
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
