{ pkgsUnstable, ... }:

{
  users.users.abhi = {
    isNormalUser = true;
    description = "Abhi";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
      "video"
      "render"
      "input"
    ];
    packages = [
      pkgsUnstable.telegram-desktop
    ];
  };
}
