{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/";
  # inputs.vmwarehorizonclient.url = "github:nixos/nixpkgs/00205055ce9ed57333f28b4023d19a2d74b3745f";
  # inputs.vmware-horizon-client.inputs.nixpkgs.follows = "nixpkgs";
  # inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  # inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
  # inputs.yandex-browser.url = "github:Teu5us/nix-yandex-browser";
  inputs.yandex-browser.url = "github:miuirussia/yandex-browser.nix";
  # inputs.yandex-browser.url = "github:spiage/nix-yandex-browser";
  inputs.yandex-browser.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  # inputs.ki-editor.url = "github:ki-editor/ki-editor";
  # inputs.ki-editor.inputs.nixpkgs.follows = "nixpkgs";
  # inputs.microvm.url = "github:astro/microvm.nix";
  # inputs.microvm.inputs.nixpkgs.follows = "nixpkgs";
  inputs.proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
  # inputs.nix-snapd.url = "github:nix-community/nix-snapd";
  # inputs.nix-snapd.inputs.nixpkgs.follows = "nixpkgs";
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  # inputs.nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
  outputs = { 
    self
  # , determinate
  , nixpkgs
  , nixos-hardware
  , yandex-browser
  # , vmwarehorizonclient
  # , ki-editor
  # , nixpkgs-unstable
  # , microvm
  , proxmox-nixos
  # , nix-snapd
  , vscode-server
  # , nix-flatpak
  }@inputs: {
    nixosConfigurations.a7 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        machines/a7.nix
        # nix-flatpak.nixosModules.nix-flatpak
        # determinate.nixosModules.default
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-cpu-amd-pstate
        # nixos-hardware.nixosModules.common-cpu-amd-zenpower ## отключил, так как он отрубает на моём 7950x нормальное управление питанием и скоростью
        nixos-hardware.nixosModules.common-cpu-amd-raphael-igpu
        nixos-hardware.nixosModules.common-gpu-amd
        nixos-hardware.nixosModules.common-hidpi
        nixos-hardware.nixosModules.common-pc
        nixos-hardware.nixosModules.common-pc-ssd
        # nixos-hardware.nixosModules.common-pc-hdd # deprecated

        # proxmox-nixos.nixosModules.proxmox-ve

        # ({ pkgs, lib, ... }: {
        #   services.proxmox-ve = {
        #     enable = true;
        #     ipAddress = "192.168.0.1";
        #   };

        #   nixpkgs.overlays = [
        #     proxmox-nixos.overlays."x86_64-linux"
        #   ];

        #   # The rest of your configuration...
        # })
        # nix-snapd.nixosModules.default
        # {
        #   services.snap.enable = true;
        # }
        vscode-server.nixosModules.default
        ({ config, pkgs, ... }: {
          services.vscode-server.enable = true;
        })
      ];
      specialArgs.inputs = inputs;
    };
    nixosConfigurations.j4 = nixpkgs.lib.nixosSystem {
      modules = [ 
        machines/j4.nix
        vscode-server.nixosModules.default
        ({ config, pkgs, ... }: {
          services.vscode-server.enable = true;
        })
      ];
      specialArgs.inputs = inputs;
      system = "x86_64-linux";
    };
    nixosConfigurations.i9 = nixpkgs.lib.nixosSystem {
      modules = [ 
        machines/i9.nix
        vscode-server.nixosModules.default
        ({ config, pkgs, ... }: {
          services.vscode-server.enable = true;
        })
      ];
      specialArgs.inputs = inputs;
      system = "x86_64-linux";
    };
    nixosConfigurations.i7 = nixpkgs.lib.nixosSystem {
      modules = [ 
        machines/i7.nix
        vscode-server.nixosModules.default
        ({ config, pkgs, ... }: {
          services.vscode-server.enable = true;
        })
      ];
      specialArgs.inputs = inputs;
      system = "x86_64-linux";
    };
    nixosConfigurations.q1 = nixpkgs.lib.nixosSystem {
      modules = [ 
        machines/q1.nix
        vscode-server.nixosModules.default
        ({ config, pkgs, ... }: {
          services.vscode-server.enable = true;
        })
      ];
      specialArgs.inputs = inputs;
      system = "x86_64-linux";
    };
  };
}
