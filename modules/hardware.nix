{ pkgs, ... }:

{
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable32Bit = true;

  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-elan;
}
