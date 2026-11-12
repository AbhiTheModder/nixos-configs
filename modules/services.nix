{ config, pkgs, primaryUser, ... }:

let
  home = config.users.users.${primaryUser}.home;
in

{
  services.printing.enable = true;

  services.tailscale.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "lock";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "lock";
  };

  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ primaryUser ];
    };
  };

  systemd.user.services.mechvibes-lite = {
    description = "Mechvibes Lite Daemon";
    after = [
      "graphical-session.target"
      "pipewire.service"
    ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.mechvibes-lite}/bin/mvibes daemon";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  systemd.user.services.bunnylol = {
    description = "bunnylol Smart Bookmark Server";
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.bunnylol}/bin/bunnylol serve";
      Restart = "on-failure";
      RestartSec = "3s";
    };
  };

  systemd.user.services.sesori-bridge = {
    description = "Sesori AI Coding Sessions Bridge";
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'exec ${home}/.local/bin/sesori-bridge --opencode-bin ${home}/.opencode/bin/opencode --opencode-no-auto-start --opencode-host 127.0.0.1 --opencode-port 49374 --opencode-password \"$(${pkgs.jq}/bin/jq -r .password ${home}/.config/opencode/service.json)\"'";
      Environment = "PATH=${pkgs.procps}/bin:/run/current-system/sw/bin";
      Restart = "always";
      RestartSec = "5s";
    };
  };

  services.tor = {
    enable = true;
    client.enable = true;
  };
}
