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
    ./modules/gnome.nix
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
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];
  nixpkgs.overlays = [
    inputs.ida-pro-overlay.overlays.default
    (import ./pkgs { inherit inputs system; })
  ];

  system.stateVersion = "25.05";
}
