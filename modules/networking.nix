{ config, lib, pkgs, ... }:

{
  networking.hostName = "btw";
  networking.wireless.enable = lib.mkForce false;

  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "interface-name:wg0" ];
  networking.networkmanager.wifi = {
    powersave = false;
    backend = "iwd";
    macAddress = "stable";
  };
  networking.resolvconf.enable = true;

  networking.wg-quick.interfaces.wg0.configFile =
    "${config.users.users.abhi.home}/.config/nixos/wireguard-wg0.conf";

  system.activationScripts.local-hosts = {
    text = ''
      if [ -f /home/abhi/.config/nixos/local-hosts ]; then
        hosts_tmp=$(mktemp)
        cp -f /etc/hosts "$hosts_tmp"

        while read -r ip host port rest; do
          [ -z "$ip" ] && continue
          echo "$ip $host" >> "$hosts_tmp"

          if [ -n "$port" ]; then
            ${pkgs.iptables}/bin/iptables -t nat -D OUTPUT -d "$ip" -p tcp --dport 80 -j DNAT --to-destination "$ip:$port" 2>/dev/null || true
            ${pkgs.iptables}/bin/iptables -t nat -A OUTPUT -d "$ip" -p tcp --dport 80 -j DNAT --to-destination "$ip:$port"
          fi
        done < /home/abhi/.config/nixos/local-hosts

        mv -f "$hosts_tmp" /etc/hosts
        chmod 0644 /etc/hosts
      fi
    '';
    deps = [ "etc" ];
  };
}
