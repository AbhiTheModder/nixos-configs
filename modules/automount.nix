{ pkgs, lib, ... }:

let
  gio = pkgs.glib.bin;
  gvfs = pkgs.gvfs;

  auto-mount-mtp = pkgs.writeShellScriptBin "auto-mount-mtp" ''
    export GIO_EXTRA_MODULES=${gvfs}/lib/gio/modules
    export XDG_RUNTIME_DIR=/run/user/$(id -u)
    export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus

    for i in $(seq 1 30); do
      uri=$(${gio}/bin/gio mount -li 2>/dev/null | \
        ${pkgs.gnugrep}/bin/grep -A5 "GProxyVolumeMonitorMTP" | \
        ${pkgs.gnugrep}/bin/grep "activation_root=" | \
        ${pkgs.gnused}/bin/sed 's/.*activation_root=//')
      if [ -n "$uri" ]; then
        ${gio}/bin/gio mount "$uri" 2>/dev/null
        exit 0
      fi
      sleep 0.2
    done
  '';
in
{
  services.udisks2.enable = true;

  services.gvfs = {
    enable = true;
    package = gvfs;
  };

  environment.systemPackages = with pkgs; [
    udiskie
    gvfs
    jmtpfs
    auto-mount-mtp
    glib.bin
  ];

  systemd.user.services.udiskie = {
    description = "Udiskie - removable disk automounter";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.udiskie}/bin/udiskie --automount --notify --tray";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  # Trigger auto-mount-mtp as a user service when MTP/USB devices are plugged in
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ENV{ID_MTP_DEVICE}=="1", RUN+="${pkgs.systemd}/bin/systemd-run --uid=1000 --gid=100 --setenv=GIO_EXTRA_MODULES=${gvfs}/lib/gio/modules --setenv=XDG_RUNTIME_DIR=/run/user/1000 --setenv=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus ${auto-mount-mtp}/bin/auto-mount-mtp"
    ACTION=="add", SUBSYSTEM=="usb", ENV{ID_USB_DRIVER}=="usbfs", RUN+="${pkgs.systemd}/bin/systemd-run --uid=1000 --gid=100 --setenv=GIO_EXTRA_MODULES=${gvfs}/lib/gio/modules --setenv=XDG_RUNTIME_DIR=/run/user/1000 --setenv=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus ${auto-mount-mtp}/bin/auto-mount-mtp"
  '';
}