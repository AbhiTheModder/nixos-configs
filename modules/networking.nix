{ lib, ... }:

{
  networking.hostName = "btw";
  networking.wireless.enable = lib.mkForce false;

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi = {
    powersave = false;
    backend = "iwd";
    macAddress = "stable";
  };
  networking.resolvconf.enable = true;
}
