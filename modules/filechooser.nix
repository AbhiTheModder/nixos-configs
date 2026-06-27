{ pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-termfilechooser
      xdg-desktop-portal-gtk
    ];
    config = {
      mango = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      };
    };
  };

  environment.etc."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd = ${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
    default_dir = $HOME
    env = TERMCMD=wezterm start --class termfilechooser
    env = PATH=$PATH:/run/current-system/sw/bin
    open_mode = suggested
    save_mode = last
  '';

  system.activationScripts.termfilechooser-config.text = ''
    mkdir -p /home/abhi/.config/xdg-desktop-portal-termfilechooser
    cp /etc/xdg-desktop-portal-termfilechooser/config /home/abhi/.config/xdg-desktop-portal-termfilechooser/config
    chown abhi:users /home/abhi/.config/xdg-desktop-portal-termfilechooser/config
  '';
}
