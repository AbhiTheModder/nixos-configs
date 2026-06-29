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
    ./modules/automount.nix
    ./modules/filechooser.nix
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
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://yazi.cachix.org"
      "https://wezterm.cachix.org"
      "https://helix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  gtk.iconCache.enable = true;

  environment.etc."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name=Adwaita
    gtk-theme-name=Adwaita
  '';

  environment.etc."gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name=Adwaita
    gtk-theme-name=Adwaita
  '';

  nixpkgs.overlays = [
    inputs.radare2.overlays.default
    inputs.ida-pro-overlay.overlays.default
    inputs.yazi.overlays.default
    inputs.helix.overlays.default
    (import ./pkgs { inherit inputs system; })
  ];

  system.stateVersion = "25.05";
}
