{ pkgsUnstable, ... }:

{
  users.groups.ideapad_laptop = {};

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
      "ideapad_laptop"
    ];
    packages = [
      pkgsUnstable.telegram-desktop
    ];
  };
}
