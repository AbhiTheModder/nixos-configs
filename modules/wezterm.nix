{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  wezterm = inputs.wezterm.packages.${system}.default;
in
{
  environment.etc."wezterm/wezterm.lua".source = ./wezterm.lua;

  programs.bash.interactiveShellInit = ''
    if [[ -n "''${WEZTERM_PANE-}" ]]; then
      source ${wezterm}/etc/profile.d/wezterm.sh
    fi
  '';

  system.activationScripts.wezterm-config.text = ''
    install -d -m 0755 -o abhi -g users /home/abhi/.config/wezterm
    install -m 0644 -o abhi -g users \
      /etc/wezterm/wezterm.lua \
      /home/abhi/.config/wezterm/wezterm.lua
  '';
}
