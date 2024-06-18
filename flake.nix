{

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs
    , vscode-server 
  }@inputs: {
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
  };
}
