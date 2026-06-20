{ pkgs, pkgsUnstable, ... }:

{
  environment.systemPackages =
    with pkgs;
    [
      wget
      git
      gh
      zip
      unzip
      microfetch
      scrcpy
      mediawriter
      distrobox
      jdk17
      fixPythonPkg
      eza
      bun
      vlc
      helix
      wl-clipboard
      delta
      nixd
      nixfmt-rfc-style
      croc
      kdePackages.kdenlive
      wshowkeys
      axel
      ripgrep
      iaito
      jadx
      frida-tools
      burpsuite
      imhex
      ida-pro
      apple-cursor
      kdePackages.ark
      handbrake
      zen-browser
      logseq
      onlyoffice-desktopeditors
      upscayl
      mechvibes-lite
      bunnylol
      python3
      python3Packages.pip
    ]
    ++ (with pkgsUnstable; [
      android-studio
      ty
      ruff
      zed-editor-fhs
      proton-vpn-cli
      wezterm
    ]);
}
