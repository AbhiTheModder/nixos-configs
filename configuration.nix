{
  config,
  pkgs,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [
    ./hardware-configuration.nix

    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/networking.nix
    ./modules/locale.nix
    ./modules/mango.nix
    ./modules/audio.nix
    ./modules/fonts.nix
    ./modules/virtualization.nix
    ./modules/programs.nix
    ./modules/packages.nix
    ./modules/users.nix
    ./modules/env.nix
    ./modules/services.nix
  ];

  nix.settings = {
    max-jobs = 8;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];
  nixpkgs.overlays = [
    inputs.radare2.overlays.default
    inputs.ida-pro-overlay.overlays.default
    (import ./pkgs { inherit inputs system; })
  ];

  system.stateVersion = "25.05";
}
