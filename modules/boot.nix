{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.i2c.enable = true;
  boot.initrd.kernelModules = [
    "amdgpu"
    "i2c-dev"
  ];
}
