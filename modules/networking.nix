{ config, lib, pkgs, primaryUser, ... }:

let
  home = config.users.users.${primaryUser}.home;

  useWireguard = false;
  useOpenvpn = false;
in

{
  networking.hostName = "btw";
  networking.wireless.enable = lib.mkForce false;

  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = lib.optionals useWireguard [ "interface-name:wg0" ];
  networking.networkmanager.wifi = {
    powersave = false;
    backend = "iwd";
    macAddress = "stable";
  };
  networking.resolvconf.enable = true;

  networking.wg-quick.interfaces = lib.optionalAttrs useWireguard {
    wg0.configFile = "${home}/.config/nixos/wireguard-wg0.conf";
  };

  services.openvpn.servers = lib.optionalAttrs useOpenvpn {
    academy = {
      autoStart = true;
      updateResolvConf = true;
      config = ''
        config ${home}/.config/nixos/openvpn-academy.ovpn
      '';
    };
  };

  system.activationScripts.local-hosts = {
    text = ''
      if [ -f ${home}/.config/nixos/local-hosts ]; then
        hosts_tmp=$(mktemp)
        cp -f /etc/hosts "$hosts_tmp"

        while read -r ip host port rest; do
          [ -z "$ip" ] && continue
          echo "$ip $host" >> "$hosts_tmp"

          if [ -n "$port" ]; then
            ${pkgs.iptables}/bin/iptables -t nat -D OUTPUT -d "$ip" -p tcp --dport 80 -j DNAT --to-destination "$ip:$port" 2>/dev/null || true
            ${pkgs.iptables}/bin/iptables -t nat -A OUTPUT -d "$ip" -p tcp --dport 80 -j DNAT --to-destination "$ip:$port"
          fi
        done < ${home}/.config/nixos/local-hosts

        mv -f "$hosts_tmp" /etc/hosts
        chmod 0644 /etc/hosts
      fi
    '';
    deps = [ "etc" ];
  };
}
