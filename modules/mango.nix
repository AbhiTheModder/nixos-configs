{ config, pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [
    inputs.mangowm.nixosModules.mango
  ];

  programs.mango.enable = true;

  xdg.portal.wlr.settings.screencast = {
    chooser_type = "dmenu";
    chooser_cmd = "${pkgs.wmenu}/bin/wmenu";
  };

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "mango";
        user = "abhi";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd mango";
        user = "greeter";
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;

  hardware.bluetooth.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  xdg.terminal-exec.enable = true;
  xdg.terminal-exec.settings.default = [ "org.wezfurlong.wezterm.desktop" ];

  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${system}.default

    gnome-disk-utility
  ];

  security.wrappers.wshowkeys = {
    source = "${pkgs.wshowkeys}/bin/wshowkeys";
    setuid = true;
    owner = "root";
    group = "root";
  };

  environment.etc."mango/config.conf".text = ''
    monitorrule=name:^HDMI-A-1$,width:3840,height:2160,refresh:60,x:1920,y:0,scale:1.5
    monitorrule=name:^eDP-1$,width:1920,height:1080,refresh:60,x:0,y:0,scale:1

    env=QT_AUTO_SCREEN_SCALE_FACTOR,1
    env=GDK_SCALE,1

    cursor_size=32
    cursor_theme=macOS
    trackpad_natural_scrolling=1
    border_radius=8
    borderpx=2
    focuscolor=0x5e81acff
    drag_tile_to_tile=1
    ov_tab_mode=0

    blur=1
    blur_layer=1
    blur_optimized=1
    blur_params_radius=5
    blur_params_num_passes=2
    blur_params_noise=0.02
    blur_params_brightness=0.9
    blur_params_contrast=0.9
    blur_params_saturation=1.2
    shadows=1
    layer_shadows=0
    shadow_only_floating=1
    shadows_size=10
    shadows_blur=15
    shadowscolor=0x00000060
    focused_opacity=0.92
    unfocused_opacity=0.82

    layerrule=noblur:1,noshadow:1,layer_name:noctalia-bar-default
    layerrule=noblur:1,noshadow:1,layer_name:noctalia-notification
    layerrule=noblur:1,noshadow:1,layer_name:noctalia-dock
    layerrule=noblur:1,noshadow:1,layer_name:noctalia-panel
    layerrule=noblur:1,noshadow:1,layer_name:noctalia-osd

    windowrule=isfloating:1,isoverlay:1,appid:zen,title:Picture-in-Picture

    exec-once=noctalia

    bind=Super,Return,spawn,wezterm
    bind=Super,b,spawn,zen
    bind=Alt,Q,killclient
    bind=Super,M,quit
    bind=Super,F,togglefullscreen
    bind=Super,R,setkeymode,resize
    bind=Alt,Tab,focusstack,next
    bind=Shift+Alt,Tab,focusstack,prev
    bind=Alt+Shift,Left,exchange_client,left
    bind=Alt+Shift,Right,exchange_client,right
    bind=Alt+Shift,Up,exchange_client,up
    bind=Alt+Shift,Down,exchange_client,down
    bind=Ctrl,1,view,1
    bind=Ctrl,2,view,2
    bind=Ctrl,3,view,3
    bind=Ctrl,4,view,4
    bind=Ctrl,5,view,5
    bind=Ctrl,6,view,6
    bind=Ctrl,7,view,7
    bind=Ctrl,8,view,8
    bind=Ctrl,9,view,9
    bind=Alt,1,tag,1
    bind=Alt,2,tag,2
    bind=Alt,3,tag,3
    bind=Alt,4,tag,4
    bind=Alt,5,tag,5
    bind=Alt,6,tag,6
    bind=Alt,7,tag,7
    bind=Alt,8,tag,8
    bind=Alt,9,tag,9

    bind=SUPER,space,spawn,noctalia msg panel-toggle launcher
    bind=SUPER,d,spawn,noctalia msg panel-toggle launcher
    bind=SUPER,s,spawn,noctalia msg panel-toggle control-center
    bind=SUPER,comma,spawn,noctalia msg settings-toggle
    bind=SUPER,V,spawn,noctalia msg panel-toggle clipboard
    bind=SUPER,O,toggleoverview

    bind=SUPER,K,spawn_shell,pkill wshowkeys || wshowkeys -a bottom -F 'Sans Bold 20' -s '#B5B520ff' -f '#ecd29cff' -b '#201B1488' -l 60

    bind=NONE,XF86AudioRaiseVolume,spawn,noctalia msg volume-up
    bind=NONE,XF86AudioLowerVolume,spawn,noctalia msg volume-down
    bind=NONE,XF86AudioMute,spawn,noctalia msg volume-mute
    bind=NONE,XF86AudioMicMute,spawn,noctalia msg mic-mute
    bind=NONE,XF86MonBrightnessUp,spawn,noctalia msg brightness-up
    bind=NONE,XF86MonBrightnessDown,spawn,noctalia msg brightness-down
    bind=NONE,Print,spawn,noctalia msg screenshot-region
    bind=SHIFT,Print,spawn,noctalia msg screenshot-fullscreen

    keymode=resize
    bind=NONE,Left,resizewin,-20,0
    bind=NONE,Right,resizewin,+20,0
    bind=NONE,Up,resizewin,0,-20
    bind=NONE,Down,resizewin,0,+20
    bind=NONE,Escape,setkeymode,default
    bind=NONE,Return,setkeymode,default

    keymode=default

    mousebind=SUPER,btn_left,moveresize,curmove
    mousebind=SUPER,btn_right,moveresize,curresize
  '';

  environment.etc."noctalia/plugins/utc-clock/plugin.toml".text = ''
    id = "abhi/utc-clock"
    name = "UTC Clock"
    version = "1.0.0"
    min_noctalia = "5.0.0"
    author = "abhi"
    description = "Toggle between local and UTC time"

    [[widget]]
    id = "clock"
    entry = "clock.luau"

      [[widget.setting]]
      key = "show_utc"
      type = "bool"
      label = "Start in UTC"
      default = false
  '';

  environment.etc."noctalia/plugins/utc-clock/clock.luau".text = ''
    local show_utc = barWidget.getConfig("show_utc")

    function update()
        noctalia.setUpdateInterval(1000)
        if show_utc then
            noctalia.runAsync("TZ=UTC date +'%H:%M  %Z'", function(result)
                barWidget.setText(result.stdout:match("^%s*(.-)%s*$"))
                barWidget.setTooltip("Right-click for local time")
            end)
        else
            noctalia.runAsync("date +'%H:%M'", function(result)
                barWidget.setText(result.stdout:match("^%s*(.-)%s*$"))
                barWidget.setTooltip("Right-click for UTC time")
            end)
        end
    end

    function onClick()
        show_utc = not show_utc
    end
  '';

  environment.etc."noctalia/config.toml".text = ''
    [shell.panel]
    transparency_mode = "soft"
    borders = false
    shadow = false

    [bar.default]
    auto_hide = true
    reserve_space = false
  '';

  system.activationScripts.noctalia-config.text = ''
    mkdir -p /home/abhi/.local/share/noctalia/plugins/utc-clock
    cp /etc/noctalia/plugins/utc-clock/plugin.toml /home/abhi/.local/share/noctalia/plugins/utc-clock/plugin.toml
    cp /etc/noctalia/plugins/utc-clock/clock.luau /home/abhi/.local/share/noctalia/plugins/utc-clock/clock.luau
    chown -R abhi:users /home/abhi/.local/share/noctalia/plugins/utc-clock
  '';

  system.activationScripts.mango-config.text = ''
    mkdir -p /home/abhi/.config/mango
    cp /etc/mango/config.conf /home/abhi/.config/mango/config.conf
    chown abhi:users /home/abhi/.config/mango/config.conf
  '';
}
