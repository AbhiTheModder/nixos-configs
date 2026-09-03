{ pkgs, ... }:

{
  security.rtkit.enable = true;

  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber.extraConfig."echo-dot-a2dp" = {
      "monitor.bluez.rules" = [
        {
          matches = [
            {
              "api.bluez5.address" = "48:5F:2D:E3:A9:99";
            }
          ];
          actions = {
            "update-props" = {
              "bluez5.auto-connect" = [ "a2dp_sink" ];
            };
          };
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    easyeffects
    deepfilternet
  ];
}
