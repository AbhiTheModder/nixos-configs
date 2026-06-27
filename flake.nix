{
  description = "abhi's nix config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    fix-python.url = "github:GuillaumeDesforges/fix-python";

    ida-pro-overlay = {
      url = "github:msanft/ida-pro-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    radare2 = {
      url = "github:radareorg/radare2";
    };
    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wezterm = {
      url = "github:wezterm/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      fix-python,
      nixpkgs-unstable,
      zen-browser,
      mangowm,
      noctalia,
      radare2,
      yazi,
      wezterm,
      ...
    }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.btw = lib.nixosSystem {

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
