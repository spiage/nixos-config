{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/";
  inputs.yandex-browser.url = "github:miuirussia/yandex-browser.nix";
  inputs.yandex-browser.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  inputs.max-messenger.url = "github:spiage/max-messenger";
  inputs.max-messenger.inputs.nixpkgs.follows = "nixpkgs";
  inputs.supernika.url = "path:/home/spiage/repos/spiage/supernika";
  inputs.supernika.inputs.nixpkgs.follows = "nixpkgs";  
  # inputs.express-messenger.url = "github:spiage/express-messenger";
  # inputs.express-messenger.inputs.nixpkgs.follows = "nixpkgs";  
  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;

      mkNixOSConfig =
        machine:
        lib.nixosSystem {
          system = if machine == "s10" then "i686-linux" else "x86_64-linux";
          modules = [ (./machines + "/${machine}.nix") ];
          specialArgs = { inherit inputs; };
        };

      machines = [
        "a7"
        "j4"
        "i9"
        "i7"
        "q1"
        "a2"
        "s9"
        "z1"
        "s10"
      ];

    in
    {
      nixosConfigurations = lib.genAttrs machines mkNixOSConfig;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
