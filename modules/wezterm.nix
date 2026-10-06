{ config, pkgs, inputs, primaryUser, ... }:

let
  home = config.users.users.${primaryUser}.home;
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
    install -d -m 0755 -o ${primaryUser} -g users ${home}/.config/wezterm
    install -m 0644 -o ${primaryUser} -g users \
      /etc/wezterm/wezterm.lua \
      ${home}/.config/wezterm/wezterm.lua
  '';
}
