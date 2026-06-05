{ pkgs, ... }:

{
  xdg.terminal-exec.enable = true;
  xdg.terminal-exec.settings.default = ["org.wezfurlong.wezterm.desktop"];

  services.xserver.enable = true;
  services.xserver.excludePackages = with pkgs; [ xterm ];

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-apps.enable = false;
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    nautilus
    gnome-calculator
    gnome-disk-utility
    gnome-tweaks
    gnome-system-monitor
    fragments
    switcheroo
    resources
    loupe
    decibels

    # gnomeExtensions.focus
    gnomeExtensions.vitals
    gnomeExtensions.app-hider
    # gnomeExtensions.arcmenu
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.color-picker
    gnomeExtensions.compact-top-bar
    gnomeExtensions.compiz-windows-effect
    gnomeExtensions.desktop-cube
    gnomeExtensions.do-not-disturb-while-screen-sharing-or-recording
    gnomeExtensions.ideapad-controls
    # gnomeExtensions.open-bar
    gnomeExtensions.emoji-copy
    gnomeExtensions.appindicator
    gnomeExtensions.utcclock
  ];
}
