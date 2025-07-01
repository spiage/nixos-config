{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/";
  inputs.yandex-browser.url = "github:miuirussia/yandex-browser.nix";
  inputs.yandex-browser.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  # inputs.nixpkgs-old.url = "github:NixOS/nixpkgs/af3da081316501d9744dbb4d988fafcdda2bf6cb";
  outputs = { 
    self
  , nixpkgs
  , nixos-hardware
  , yandex-browser
  , proxmox-nixos
  , vscode-server
  # , nixpkgs-old
  }@inputs: {
    nixosConfigurations.a7 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 

        # ({ config, pkgs, ... }: {
        #   nixpkgs.overlays = [
        #     (final: prev: {
        #       # Импортируем только xrdp из старого nixpkgs
        #       xrdp = (import inputs.nixpkgs-old {
        #         system = "x86_64-linux";
        #         config.allowUnfree = true;
        #       }).xrdp;
        #     })
        #   ];

        #   services.xrdp = {
        #     enable = true;
        #     package = pkgs.xrdp;  # Теперь это старая версия
        #     defaultWindowManager = "startplasma-x11";
        #     openFirewall = true;
        #     audio.enable = true;
        #   };
        # })

        machines/a7.nix
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
