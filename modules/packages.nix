{ pkgs, pkgsUnstable, inputs, ... }:

let
  # Provides `node` backed by `bun`, so tools hardcoding
  # `#!/usr/bin/env node` or spawning `node` work without nodejs.
  # A plain `ln -s bun node` can't handle `node --version` / `-v`
  # (bun's node-wrapper has no REPL/version flag), so this wrapper
  # answers version probes with bun's node compat version and
  # passes everything else through to bun.
  # Remove this if you add `nodejs` to systemPackages (bin/node collision).
  bun-as-node = pkgs.writeShellScriptBin "node" ''
    if [[ "''${1:-}" == "--version" || "''${1:-}" == "-v" ]]; then
      exec ${pkgs.bun}/bin/bun -e 'console.log(process.version)'
    fi
    exec ${pkgs.bun}/bin/bun "$@"
  '';
in
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
      bun
      bun-as-node
      vlc
      helix
      wl-clipboard
      wmenu
      ddcutil
      delta
      nixd
      nixfmt-rfc-style
      croc
      bubblewrap
      kdePackages.kdenlive
      wshowkeys
      axel
      ripgrep
      iaito
      jadx
      burpsuite
      imhex
      ida-pro
      apple-cursor
      kdePackages.ark
      handbrake
      zen-browser
      upscayl
      mechvibes-lite
      bunnylol
      python3
      python3Packages.pip
      crush
      yazi
      claude-code
      nb
      leaf
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
      codex
      antigravity-cli
      frida-tools
      # (lutris.override {
        # extraLibraries = pkgs: with pkgs; [ vulkan-loader ];
      # })
    ]);
}
