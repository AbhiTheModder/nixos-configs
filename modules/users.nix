{ pkgs, inputs, primaryUser, ... }:

{
  users.groups.ideapad_laptop = {};

  users.users.${primaryUser} = {
    isNormalUser = true;
    home = "/home/${primaryUser}";
    description = "Abhi";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
      "video"
      "render"
      "input"
      "i2c"
      "ideapad_laptop"
    ];
    packages = [
      inputs.fagram.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
