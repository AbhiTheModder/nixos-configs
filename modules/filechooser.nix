{ pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-termfilechooser
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      };
    };
  };

  environment.etc."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd = yazi-wrapper.sh
    default_dir = $HOME
    env = TERMCMD=wezterm start --class termfilechooser
    env = PATH=$PATH:/run/current-system/sw/bin
    open_mode = suggested
    save_mode = last
  '';
}