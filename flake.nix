{
  description = "abhi's nix config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    fix-python.url = "github:GuillaumeDesforges/fix-python";

    ida-pro-overlay = {
      url = "github:hideyosh1/ida-pro-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      fix-python,
      nixpkgs-unstable,
      zen-browser,
      ...
    }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.abhi = lib.nixosSystem {

        specialArgs = {
          inherit inputs;
          pkgsUnstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };

        modules = [
          ./configuration.nix
        ];
      };
    };
}
