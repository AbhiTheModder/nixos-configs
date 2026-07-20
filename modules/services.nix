{ pkgs, ... }:

{
  services.printing.enable = true;

  services.tailscale.enable = true;

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
