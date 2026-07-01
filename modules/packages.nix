{ pkgs, pkgsUnstable, inputs, ... }:

{
  environment.systemPackages =
    with pkgs;
    [
      inputs.wezterm.packages.${pkgs.stdenv.hostPlatform.system}.default
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
      nodejs
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
      crush
      yazi
      archivemount
      ripdrag
      ouch
      adwaita-icon-theme
      gnome-themes-extra
      libfaketime
      google-cloud-sdk
    ]
    ++ (with pkgsUnstable; [
      android-studio
      ty
      ruff
      zed-editor-fhs
      proton-vpn-cli
      (lutris.override {
        extraLibraries = pkgs: with pkgs; [ vulkan-loader ];
      })
    ]);
}
