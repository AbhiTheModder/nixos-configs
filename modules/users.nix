{ pkgs, pkgsUnstable, inputs, primaryUser, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  fagram = inputs.fagram.packages.${system}.default;
  fagramWithWalletEngine = fagram.overrideAttrs (old: {
    unwrapped = old.unwrapped.overrideAttrs (unwrapped: {
      buildInputs = unwrapped.buildInputs ++ [ pkgsUnstable.wallet-engine ];
    });
  });
in
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
      fagramWithWalletEngine
      pkgs.watui
    ];
  };
}
