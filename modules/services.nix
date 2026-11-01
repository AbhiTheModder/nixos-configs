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

  systemd.services.forwiroh = {
    description = "Forwiroh peer-to-peer networking daemon";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/install -d -o ${primaryUser} -g users ${home}/.local/state/forwiroh";
      ExecStart = "${home}/.local/bin/forwiroh --state ${home}/.local/state/forwiroh serve";
      User = primaryUser;
      Group = "users";
      Restart = "on-failure";
      RestartSec = "5s";
      UMask = "0077";
      NoNewPrivileges = true;
      PrivateTmp = true;
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

  services.tor = {
    enable = true;
    client.enable = true;
  };
}
