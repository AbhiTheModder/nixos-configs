{ config, lib, pkgs, primaryUser, ... }:

let
  home = config.users.users.${primaryUser}.home;

  watuiConfig = pkgs.writeText "watui-config.yaml" ''
    notifications:
      enabled: true
      banner: true
      sound: false

    daemon:
      log: true
  '';

in
{
  environment.systemPackages = [ pkgs.libnotify ];

  system.activationScripts.watui-config.text = ''
    install -d -m 0700 -o ${primaryUser} -g users ${home}/.config/watui
    install -m 0600 -o ${primaryUser} -g users \
      ${watuiConfig} \
      ${home}/.config/watui/config.yaml
  '';

}
