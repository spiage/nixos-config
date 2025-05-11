{ config, pkgs, inputs, lib, ... }:
{

  networking.hostName = "a7"; # Define your hostname.
  networking.hostId = "262de9ae";

  imports = [ 
    ../profiles/boot/systemd-boot.nix
    ../profiles/common.nix 
    ../profiles/network/smb-server.nix
  ];

  systemd.network = {
    links."10-eth0".matchConfig.MACAddress = 
      lib.concatStringsSep " " [  # Объединение через пробел
        "74:56:3c:78:21:ad"   # Физический интерфейс
        "00:15:5d:01:02:00"   # MAC Hyper-V
      ];
    
    networks = {
      "30-br0" = {
        address = [ 
          "192.168.1.2/24" 
          # Для IPv6 (если нужно):
          # "2001:db8::a7/64"
        ];
      };
    };    
  };

  # Параметры VXLAN для a7
  # vxlanConfig = {
  #   localIP = "192.168.1.2";       # Физический IP a7
  #   remoteIPs = [ "192.168.1.15" "192.168.1.18" ];  # IP i7 и q1
  #   vxlanIP = "10.10.10.3";        # VXLAN-адрес a7
  #   physicalInterface = "br0";  # Укажите ваш интерфейс (eno1, enp1s0 и т.д.)
  # };

  boot.initrd.kernelModules = [ "amdgpu" "coretemp" "hv_vmbus" "hv_storvsc" ];

  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "uas" "usbhid" "sd_mod" ];
  boot.supportedFilesystems = [ "ntfs" "btrfs" "ext4" "xfs" "zfs" ];
  boot.kernelModules = [ "kvm-amd" "bfq" "mt7921e" "k10temp" "hv_vmbus" "hv_storvsc" "hv_netvsc" "hv_utils" "hv_balloon" ];
  boot.kernelParams = [ "mitigations=off" "preempt=full" "nowatchdog" "kernel.nmi_watchdog=0" "video=hyperv_fb:800x600" ];
  boot.kernel.sysctl."vm.overcommit_memory" = "1"; # https://github.com/NixOS/nix/issues/421 # - avoid a problem with `nix-env -i` running out of memory
  boot.zfs.extraPools = [ "store_pool" ];
  services.zfs.autoScrub.enable = true;


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/26aceccc-68ac-40b5-9967-800602c65cc1";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/42EA-18D7";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/064f7210-f542-4e05-84a8-db2e6817b263";
      fsType = "btrfs";
    };

  swapDevices =
    [
#     { device = "/dev/disk/by-label/swap200"; }
    ];


  # fileSystems."/mnt/nfs" = {
  #   device = "j4:/vpool";
  #   fsType = "nfs";
  # };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  # networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp11s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp12s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  #hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  virtualisation.hypervGuest.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  # nix.package = pkgs.nixVersions.latest;

  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = lib.mkForce false;
  };
  hardware.sensor.iio.enable = true;

  # # Физический интерфейс (enp14s0) → eth0
  # services.udev.extraRules = ''
  #   SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="74:56:3c:78:21:ad", NAME="eth0" SYMLINK+="enp14s0-physical"
  #   SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:15:5d:01:02:00", NAME="eth0" SYMLINK+="hv-eth0-virtual"
  # '';

#   systemd.network.networks."main-eth" = {
#     matchConfig.Name = "eth0";
#     address = ["192.168.1.2/24"];
#     gateway = ["192.168.1.1"];
#     dns = ["192.168.1.1"];
#     networkConfig = {
#       DHCP = "no";
#       Domains = "k8s.local";
#     };
#   };
#   # networking.useDHCP = false;
  
#   networking = {
#     usePredictableInterfaceNames = false; 
# #    bridges.br0.interfaces = [ "enp14s0" ];
#     bridges.br0.interfaces = [ "eth0" ];
#     # useDHCP = false;
# #    interfaces.enp14s0.useDHCP = false;
#     interfaces.eth0.useDHCP = false;
#     interfaces.br0.useDHCP = true;
#   };
#   networking.dhcpcd.extraConfig = "noipv6rs"; 
  # networking.bridges.vmbr0.interfaces = [ "enp14s0" ];
  # networking.interfaces.vmbr0.useDHCP = lib.mkDefault true;

  # В /etc/nixos/configuration.nix
  # systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = [
  #   ""
  #   "${pkgs.networkmanager}/bin/nm-online -s -q --timeout=180"
  # ];  

  services.xserver.enable = true;
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:win_space_toggle";
  # services.xserver.videoDrivers = [ "amdgpu" ];
  # services.xserver.desktopManager.plasma5.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasmax11";

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = false;
  # services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.settings.General.DisplayServer = "x11-user";
#  services.displayManager.autoLogin.enable = true;
#  services.displayManager.autoLogin.user = "spiage";

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
  services.xrdp.openFirewall = true;
  services.xrdp.audio.enable = true;

  services.libinput.enable = true;
  # services.fwupd.enable = true;

  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    # nerdfonts
    terminus_font
    nerd-fonts.terminess-ttf
    # terminus-nerdfont
    cascadia-code 
    # fonts.packages = lib.mkIf cfg.enableDefaultPackages (
    #   with pkgs;
    #   [
    dejavu_fonts
    freefont_ttf
    gyre-fonts # TrueType substitutes for standard PostScript fonts
    liberation_ttf
    unifont
    noto-fonts-color-emoji
      # ]
  ];
  
  #scanner
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.ipv6 = false;
  ###

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # чтобы избежать "Too many open files"
  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "99999";
  }];

  virtualisation.libvirtd.allowedBridges = [ "virbr1" "virbr0" "br0" ];
  programs.virt-manager.enable = true;
  # virtualisation.xen.enable = lib.mkForce false;

  # networking.nftables.enable = true; # - Incus on NixOS is unsupported using iptables. Set `networking.nftables.enable = true;`
  # networking.firewall.trustedInterfaces = [ "incusbr0" ];
  virtualisation = {
    # incus = {
    #   enable = true;
    #   ui.enable = true;
    # };
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
  # virtualisation.docker.enable = true;
  # # virtualisation.docker.extraOptions =
  # #   ''--iptables=false --ip-masq=false -b br0'';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ks = {
    isNormalUser = true;
    description = "ks";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "audio" "incus-admin" "kvm" "libvirtd" "vboxusers" "video" "docker" "podman" ];
  };

  nixpkgs.config.allowUnfree = true;

  programs.kdeconnect.enable = true;

  programs.zsh.enable = true;
  programs.starship.enable = true;
  programs.starship.presets = [ "nerd-font-symbols" ];


  fileSystems."/mnt/smb_pub" = {
    device = "//j4/Public";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      # automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";

    # in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
    # in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=${toString config.users.users.spiage.uid},gid=${toString config.groups.users.gid}"];
    in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
  };

  services.k3s = {
    enable = true;
    role = "server";
    token = "Ee1ySKGVulT61yhl2hRDgXVP33OC8R0P"; #tr -dc A-Za-z0-9 </dev/urandom | head -c 32; echo
    clusterInit = true;
    extraFlags = "--write-kubeconfig-mode=644";
  };

  # Проблема - русские имена файлов не поддерживаются в винде :(
  # services.nfs.server = {
  #   enable = true;
  #   exports = ''
  #     /mnt/store/zstd19 192.168.1.0/24(rw,async,no_subtree_check,insecure)
  #   '';
  # };
  # networking.firewall.allowedTCPPorts = [ 2049 ]; # открыть порт NFS

  services.samba = {
    shares.testshare = {
      path = "/mnt/store/zstd19";
      writable = "true";
      comment = "Hello World!";
    };
  };

# systemd.services.zfs-mount = {
#   serviceConfig.ExecStartPost = [
#     "+${pkgs.coreutils}/bin/chmod -R 777 /mnt/store/zstd19"
#     "+${pkgs.acl}/bin/setfacl -R -m u:nobody:rwx /mnt/store/zstd19"
#   ];
# };

  # # Автоматически устанавливать права на ZFS-датасет
  # systemd.services.zfs-mount = {
  #   serviceConfig.ExecStartPost = "+${pkgs.coreutils}/bin/chmod -R 777 /mnt/store/zstd19";
  # };

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;        # Аналог X11Forwarding yes
      X11DisplayOffset = 10;       # Соответствует X11DisplayOffset 10
      X11UseLocalhost = true;      # Аналог X11UseLocalhost yes
    };
  };
  systemd.services.sshd = {
    # Не перезапускать sshd, если изменился его конфиг
    stopIfChanged = false;
    # # Явно указать критичные зависимости
    # unitConfig = {
    #   Requires = "network.target";
    #   After = "network.target";
    # };
  };
  # services.cockpit = {
  #   enable = true;
  #   # Отключите TLS, если используете локальную сеть (небезопасно для интернета!)
  #   settings = {
  #     WebService = {
  #       AllowUnencrypted = true;  # Только для доверенных сетей!
  #       Origins = lib.mkForce "http://a7 https://a7:9090";
  #       ProtocolHeader = lib.mkForce "X-Forwarded-Proto";
  #     };
  #   };
  #   openFirewall = true;
  # };  
  # nixpkgs.overlays = [ (final: prev: {
  #   pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [ (pyfinal: pyprev: {
  #     afdko = pyprev.afdko.overridePythonAttrs (oldAttrs: {
  #       doCheck = false; #test hanged
  #       doInstallCheck = false;
  #       dontCheck = true;
  #     });
  #   }) ];
  # }) ];
  # nixpkgs.overlays = [ 
  #   (
  #     final: prev: { 
  #       yandex-browser = prev.yandex-browser.overrideAttrs (_: rec { 
  #         pname = "yandex-browser-stable"; #yandex-browser-stable_24.6.1.852-1_amd64.deb   
  #         version = "24.6.1.852-1";
  #         src = prev.fetchurl {
  #           url = "http://repo.yandex.ru/yandex-browser/deb/pool/main/y/${pname}/${pname}_${version}_amd64.deb";
  #           hash = "sha256-7G2AIqV7pCCWbN2SKzcqM/OES6EDqHQKzrJTc+GXWeI=";
  #         };
  #       });
  #     }
  #   )
  # ];  
  # nixpkgs.config.permittedInsecurePackages = [
  #   "yandex-browser-stable-24.6.1.852-1"
  # ];  
  # services.tailscale.enable = true;
  programs.partition-manager.enable = true;
  services.dbus.packages = [ pkgs.kdePackages.kpmcore ];
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [ 
  #     pkgs.kdePackages.xdg-desktop-portal-kde 
  #   ];
  # };    
  
  services.gvfs.enable = true; # Browsing samba shares with GVFS
  # networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';

  # services.mongodb.enable = true;
  # vmwarehorizonclient.legacyPackages.x86_64-linux.nixpkgs.config.allowUnfree = true;
  # nixpkgs.overlays = [
  #   ( 
  #     final: prev: { 
  #       vhc = import (inputs.vmwarehorizonclient) { system = "x86_64-linux"; config.allowUnfree = true; }; 
  #     } 
  #   )
  # ];

  # services.cockpit.enable = true;

  # services.rustdesk-server.enable = true;
  # services.rustdesk-server.openFirewall = true;
  programs.obs-studio = {
    enable = true;
  };
  # virtualisation.multipass.enable = true;
  services.flatpak.enable = true;
  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [

    etcd
    
    tcpdump

    # kcat не умеет в ssl # Generic non-JVM producer and consumer for Apache Kafka
    # ERROR: Failed to create producer: No provider for SASL mechanism SCRAM-SHA-512: recompile librdkafka with libsasl2 or openssl support. Current build options: PLAIN    

    iperf3

    x11vnc

    # tuna # Thread and IRQ affinity setting GUI and cmd line tool

    lazydocker

    parted

    apparmor-bin-utils

    lynx
    
    squashfuse

    # nemu # Ncurses UI for QEMU
    # virt-viewer # Viewer for remote virtual machines

    distrobox
    distrobox-tui
    boxbuddy
    # dia
    # drawio #distrobox
    # ascii-draw
    # yed
    #obsidian #I'm tired - electron-unwrapped~=44K of builds
    zotero
    kubevirt

    libvirt

    ghostty

    terraform
    # vagrant ## hashicorp blocked RU
    sshpass

    nixos-shell

    # libsForQt5.kcmutils # inputs.kde2nix.packages.x86_64-linux.kcmutils
    kdePackages.kcmutils
    # libsForQt5.kdebugsettings # KDE debug settings
    kdePackages.kdebugsettings
    # libsForQt5.libksysguard
    kdePackages.libksysguard
    # kdePackages.krdp


    # mattermost-desktop #distrobox # Mattermost Desktop client
    # Mattermost is an open source platform for secure collaboration across the entire software development lifecycle


    # keepass # GUI password manager with strong cryptography

    keepassxc # Offline password manager with many features
    # A community fork of KeePassX, which is itself a port of KeePass Password Safe. 
    # The goal is to extend and improve KeePassX with new features and bugfixes, to provide a feature-rich, 
    # fully cross-platform and modern open-source password manager. 
    # Accessible via native cross-platform GUI, CLI, 
    # has browser integration using the KeePassXC Browser Extension (https://github.com/keepassxreboot/keepassxc-browser)    

    # zfs # ZFS Filesystem Linux Userspace Tools

    guestfs-tools # Extra tools for accessing and modifying virtual machine disk images

    cdrkit # Portable command-line CD/DVD recorder software, mostly compatible with cdrtools
      # Programs provided
      # cdda2mp3 cdda2ogg cdrecord devdump dirsplit genisoimage icedax isodebug isodump isoinfo isovfy mkisofs netscsid pitchplay readmult readom wodim

    usbutils # Tools for working with USB devices, such as lsusb

    # runc

    cifs-utils

    iotop

    xorg.xhost
    
    #ciscoPacketTracer8 # Network simulation tool from Cisco

    dig # Domain name server

    mongodb-compass

    #_broken_ apache-airflow # Programmatically author, schedule and monitor data pipelines

    yandex-cloud # Command line interface that helps you interact with Yandex Cloud services
    terraform-providers.yandex # 

    #hplipWithPlugin # Print, scan and fax HP drivers for Linux

    samba

    iio-sensor-proxy

    # tailscale # Node agent for Tailscale, a mesh VPN built on WireGuard

    # lens # Kubernetes IDE
    # trivy # Simple and comprehensive vulnerability scanner for containers, suitable for CI

    # dbeaver-bin # Free multi-platform database tool for developers, SQL programmers, database administrators and analysts. Supports all popular databases: MySQL, PostgreSQL, MariaDB, SQLite, Oracle, DB2, SQL Server, Sybase, MS Access, Teradata, Firebird, Derby, etc.

    # thunderbird-latest # 132
    # thunderbird # 128ESR
    # birdtray

    # firefox

    microsoft-edge
    inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable  
    # inputs.ki-editor.packages.x86_64-linux.default
    # yandex-browser
    google-chrome

    # inputs.nixpkgs-unstable.legacyPackages.${system}.telegram-desktop  
    telegram-desktop

    ansible # Radically simple IT automation
    # docker-compose # Docker CLI plugin to define and run multi-container applications with Docker
    # filezilla # Graphical FTP, FTPS and SFTP client

    (pkgs.zoom-us.override { xdgDesktopPortalSupport = false; }) # zoom-us # zoom.us video conferencing application
    delve # debugger for the Go programming language
    gdlv # GUI frontend for Delve
    go # The Go Programming language
    ## go env -w GO111MODULE=off (for pass error in VSCode while Ctrl+F5)

    alacritty # A cross-platform, GPU-accelerated terminal emulator
    kitty # A modern, hackable, featureful, OpenGL based terminal emulator
    wezterm # GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust
    #openlens # Kubernetes IDE
    k9s # Kubernetes IDE for console
    kompose
    #kubectl # есть в k3s, закомментировал из-за коллизии
    #kubernetes # есть в k3s, закомментировал из-за коллизии
    kubernetes-helm
    kubernetes-metrics-server

    ncdu # Disk usage analyzer with an ncurses interface

    # micro
    # helix
    # st
    libreoffice-qt6-fresh
    # vmware-horizon-client
    # inputs.vmwarehorizonclient.legacyPackages.x86_64-linux.vmware-horizon-client
    # input.vmwarehorizonclient.legacyPackages.x86_64-linux.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "vmware-horizon-client" ]
    # import input.vmwarehorizonclient { config.allowUnfree = true; inherit system; } vmware-horizon-client
    # vhc.vmware-horizon-client
    vmware-horizon-client

    mc
    oh-my-git

    git     
    vscode     
    vscode-extensions.ms-toolsai.jupyter     
    vscode-extensions.bbenoist.nix
    vscode-extensions.github.copilot
    vscode-extensions.ms-python.python
    vscode-extensions.hookyqr.beautify
    vscode-extensions.ms-vscode.cpptools
    vscode-extensions.jnoortheen.nix-ide
    vscode-extensions.ms-dotnettools.csharp
    vscode-extensions.kubukoz.nickel-syntax
    vscode-extensions.yzhang.markdown-all-in-one
    vscode-extensions.github.github-vscode-theme
    vscode-extensions.brettm12345.nixfmt-vscode
    vscode-extensions.b4dm4n.vscode-nixpkgs-fmt
    vscode-extensions.mads-hartmann.bash-ide-vscode
    vscode-extensions.davidanson.vscode-markdownlint
    vscode-extensions.ms-vscode-remote.remote-ssh
    vscode-extensions.foam.foam-vscode
    vscode-extensions.bierner.markdown-mermaid
    vscode-extensions.bierner.docs-view
    vscode-extensions.bierner.emojisense
    vscode-extensions.bierner.markdown-checkbox
    vscode-extensions.bierner.markdown-emoji
    vscode-extensions.shd101wyy.markdown-preview-enhanced
    vscode-extensions.tomoki1207.pdf
    vscode-extensions.alefragnani.bookmarks
    vscode-extensions.alefragnani.project-manager
    vscode-extensions.jebbs.plantuml
    vscode-extensions.gruntfuggly.todo-tree
    
    nixd     
    nil
    jq
    tree

    # partition-manager # inputs.kde2nix.packages.x86_64-linux.partitionmanager
    kdePackages.plasma-workspace-wallpapers #libsForQt5.plasma-workspace-wallpapers #collision with konsole from plasma 5 inputs.kde2nix.packages.x86_64-linux.plasma-workspace-wallpapers
    pavucontrol # libsForQt5.kmix deprecated #marked broken inputs.kde2nix.packages.x86_64-linux.kmix    
    # remmina # libsForQt5.krdc !vvv remmina is faster vvv!
    # skanpage
    kdePackages.ktorrent
    mpv kdePackages.dragon
    kdePackages.kcalc
    kdePackages.skanpage
    #kmines
    #libsForQt5.kpat # inputs.kde2nix.packages.x86_64-linux.kpat
    # kdePackages.discover # discover #fail with plasma 6.0.4
    kdePackages.konsole
    kdePackages.kmail
    kdePackages.kontact
    kdePackages.merkuro
    
    # apt
    # dpkg
    # debootstrap
    
    lsof

    ffmpeg #(pkgs.ffmpeg.override { withOptimisations = true; withFullDeps = true; })

    # neofetch

    #python311
    (python3.withPackages(ps: with ps; [ notebook jupyter pip requests ])) #!!! waiting for https://github.com/NixOS/nixpkgs/pull/285959
    # gcc
    # clang
    # llvm
    # dash

    sqlite
    postgresql

    nix-tree xsel #xclip #pbcopy wl-copy xsel (for 'Y to copy path')
    nvd
    qdirstat
    glxinfo
    vulkan-tools
    gpu-viewer

    flare
    wesnoth

    qemu_kvm
    # virt-manager

    podman-tui
    podman-compose

    
    # zed-editor
    anilibria-winmaclinux
    # ventoy-full
    
    nut
    lm_sensors

    masterpdfeditor
    masterpdfeditor4
    # terminator

    helvum
    qpwgraph
  ];



  system.stateVersion = lib.mkForce "23.05"; # Did you read the comment?

}
