{
  config,
  pkgs,
  inputs,
  primaryUser,
  ...
}:

let
  home = config.users.users.${primaryUser}.home;
  system = pkgs.stdenv.hostPlatform.system;
  wezterm = inputs.wezterm.packages.${system}.default;

  yaziImageOpener = pkgs.writeShellScriptBin "yazi-image-opener" ''
    if [ -n "''${WEZTERM_PANE:-}" ]; then
      exec ${wezterm}/bin/wezterm cli spawn --new-window -- ${pkgs.yazi}/bin/yazi -- "$@"
    fi
    exec ${wezterm}/bin/wezterm start --always-new-process -- ${pkgs.yazi}/bin/yazi -- "$@"
  '';

  yaziImageDesktop = pkgs.makeDesktopItem {
    name = "yazi-image";
    desktopName = "Yazi";
    comment = "Open files in Yazi";
    exec = "${yaziImageOpener}/bin/yazi-image-opener %f";
    terminal = false;
    noDisplay = true;
    mimeTypes = [
      "image/jpeg"
      "image/png"
      "image/gif"
      "image/webp"
      "image/tiff"
      "image/bmp"
      "image/svg+xml"
      "image/avif"
      "image/heic"
      "image/jxl"
    ];
  };
in
{
  environment.systemPackages = [ yaziImageDesktop ];

  system.activationScripts.yazi-image-default.text = ''
    install -d -m 0700 -o ${primaryUser} -g users ${home}/.config
    for mime in \
      image/jpeg \
      image/png \
      image/gif \
      image/webp \
      image/tiff \
      image/bmp \
      image/svg+xml \
      image/avif \
      image/heic \
      image/jxl
    do
      HOME=${home} XDG_CONFIG_HOME=${home}/.config \
        ${pkgs.xdg-utils}/bin/xdg-mime default yazi-image.desktop "$mime" || true
    done
    chown ${primaryUser}:users ${home}/.config/mimeapps.list 2>/dev/null || true
  '';
}
