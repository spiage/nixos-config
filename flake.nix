{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/";
  inputs.yandex-browser.url = "github:miuirussia/yandex-browser.nix";
  inputs.yandex-browser.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";

      mkNixOSConfig =
        machine:
        lib.nixosSystem {
          inherit system;
          modules = [ (./machines + "/${machine}.nix") ];
          specialArgs = { inherit inputs; };
        };

      machines = [
        "a7"
        "j4"
        "i9"
        "i7"
        "q1"
      ];

    in
    {
      nixosConfigurations = lib.genAttrs machines mkNixOSConfig;
      formatter.x86_64-linux = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
