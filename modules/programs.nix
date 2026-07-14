{ pkgs, ... }:

{
  programs.ghidra.enable = true;

  programs.xonsh = {
    enable = true;
    extraPackages = ps: with ps; [ pip ];
  };

  programs.bash = {
    blesh.enable = true;
    shellAliases = {
      cd = "z";
      rebuild = "nh os switch";
      reclean = "sudo rm /nix/var/nix/profiles/system-* && nh os boot";
      reboot = "sudo reboot";
      cat = "bat";
      vi = "hx";
      ls = "eza --icons";
      ".." = "cd ..";
      ":q" = "exit";
      wget = "wget -q --show-progress";
      jjar = "java -jar";
      scrcpy = "scrcpy --render-driver=opengl";
      node = "bun";
    };
    interactiveShellInit = ''
      nsu() {
        if [ $# -eq 0 ]; then
          echo "Usage: nsu <package-name>"
          return 1
        fi
        NIXPKGS_ALLOW_UNFREE=1 nix shell --impure "github:NixOS/nixpkgs/nixos-unstable#$1"
      }
    '';
    promptInit = ''
      : "$PROMPT_COMMAND:="

      PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null); '"$PROMPT_COMMAND"

      PS1='\[\e[38;5;39m\] \[\e[0m\]\[\e[38;5;46m\]┬─[\[\e[38;5;226m\]\u\[\e[0m\]@\[\e[38;5;33m\]\h\[\e[0m\]:\w\[\e[38;5;46m\]]─[\[\e[38;5;46m\]$PS1_CMD1]\n\[\e[38;5;46m\]╰─>\[\e[0m\] '
    '';
    shellInit = ''
      eval "$(direnv hook bash)"
      export NIX_CONFIG="access-tokens = github.com=$(${pkgs.gh}/bin/gh auth token)"
    '';
  };

  programs.zoxide.enable = true;
  programs.bat.enable = true;
  programs.nix-ld.enable = true;
  programs.appimage.enable = true;

  programs.direnv = {
    enable = true;
    package = pkgs.direnv;
    silent = true;
    loadInNixShell = false;
    nix-direnv = {
      enable = true;
      package = pkgs.nix-direnv;
    };
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi
      obs-gstreamer
      obs-vkcapture
      obs-advanced-masks
      droidcam-obs
    ];
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/etc/nixos";
  };

  programs.ssh = {
    startAgent =  true;
    agentTimeout = "1h";
  };
}
