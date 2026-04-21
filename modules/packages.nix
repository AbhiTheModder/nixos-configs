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
      showmethekey
      axel
      ripgrep
      iaito
      jadx
      frida-tools
      burpsuite
      imhex
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

      (callPackage ida-pro {
        runfile = fetchurl {
          url = "https://pintobyte.com/tmp/ida-pro_91_x64linux.run";
          hash = "sha256-j/CAIr46DvaTqePqAQENE1aybP3Lvn/daNAbPJcA+eI=";
        };
      })
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
