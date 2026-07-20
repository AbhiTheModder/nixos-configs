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

  systemd.tmpfiles.rules = [
    "z /sys/bus/platform/drivers/ideapad_acpi/*/conservation_mode 0664 root ideapad_laptop"
    "z /sys/bus/platform/drivers/ideapad_acpi/*/fan_mode 0664 root ideapad_laptop"
    "z /sys/bus/platform/drivers/ideapad_acpi/*/fn_lock 0664 root ideapad_laptop"
    "z /sys/bus/platform/drivers/ideapad_acpi/*/touchpad 0664 root ideapad_laptop"
    "z /sys/bus/platform/drivers/ideapad_acpi/*/camera_power 0664 root ideapad_laptop"
    "z /sys/bus/platform/drivers/ideapad_acpi/*/usb_charging 0664 root ideapad_laptop"
  ];

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
    focuscolor=0xa5d590ff
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
    plugin_api = 4
    author = "abhi"

    [[widget]]
    id = "clock"
    entry = "clock.luau"

      [[widget.setting]]
      key = "show_utc"
      type = "bool"
      label_key = "settings.show_utc.label"
      default = false
  '';

  environment.etc."noctalia/plugins/utc-clock/clock.luau".text = ''
    local show_utc = noctalia.getConfig("show_utc")

    function update()
        noctalia.setUpdateInterval(1000)
        if show_utc then
            noctalia.runAsync("TZ=UTC date +'%H:%M  %Z'", function(result)
                if result.exitCode == 0 then
                    barWidget.setText(noctalia.string.trim(result.stdout))
                    barWidget.setTooltip("Right-click for local time")
                end
            end)
        else
            noctalia.runAsync("date +'%H:%M'", function(result)
                if result.exitCode == 0 then
                    barWidget.setText(noctalia.string.trim(result.stdout))
                    barWidget.setTooltip("Right-click for UTC time")
                end
            end)
        end
    end

    function onClick()
        show_utc = not show_utc
    end
  '';

  environment.etc."noctalia/plugins/utc-clock/translations/en.json".text = ''
    {
      "settings.show_utc.label": "Start in UTC"
    }
  '';

  environment.etc."noctalia/plugins/ideapad-controls/plugin.toml".text = ''
    id = "abhi/ideapad-controls"
    name = "IdeaPad Controls"
    version = "1.0.0"
    plugin_api = 4
    author = "abhi"
    description = "Control Lenovo IdeaPad laptop features"
    icon = "laptop"

    [[widget]]
    id = "status"
    entry = "widget.luau"

      [[widget.setting]]
      key = "default_option"
      type = "select"
      label_key = "settings.default_option.label"
      default = "conservation_mode"
      options = [
        { value = "conservation_mode", label_key = "option.conservation_mode" },
        { value = "fan_mode", label_key = "option.fan_mode" },
        { value = "fn_lock", label_key = "option.fn_lock" },
        { value = "usb_charging", label_key = "option.usb_charging" },
      ]

    [[panel]]
    id = "control"
    entry = "panel.luau"
    width = 320
    height = 300
    placement = "attached"
    position = "auto"
    open_near_click = true
  '';

  environment.etc."noctalia/plugins/ideapad-controls/widget.luau".text = ''
    local default_option = noctalia.getConfig("default_option")

    local OPTIONS = {"conservation_mode", "fan_mode", "fn_lock", "usb_charging"}
    local GLYPHS = {
      conservation_mode = "battery-charging",
      fan_mode = "fan",
      fn_lock = "keyboard",
      usb_charging = "usb",
    }
    local LABELS = {
      conservation_mode = "Cons",
      fan_mode = "Fan",
      fn_lock = "FnLk",
      usb_charging = "USB",
    }

    local sysfs_base = ""
    local available = {}
    local current_option = ""
    local current_value = "0"

    local function detect()
      local entries = noctalia.listDir("/sys/bus/platform/drivers/ideapad_acpi")
      if entries == nil then return end
      for _, entry in ipairs(entries) do
        if entry ~= "bind" and entry ~= "unbind" and entry ~= "module" and entry ~= "uevent" then
          local path = "/sys/bus/platform/drivers/ideapad_acpi/" .. entry .. "/"
          if noctalia.fileExists(path .. "conservation_mode") or noctalia.fileExists(path .. "fn_lock") then
            sysfs_base = path
            break
          end
        end
      end
      if sysfs_base == "" then return end
      for _, opt in ipairs(OPTIONS) do
        if noctalia.fileExists(sysfs_base .. opt) then
          table.insert(available, opt)
        end
      end
    end

    local function readOption(opt)
      local content = noctalia.readFile(sysfs_base .. opt)
      if content then
        return noctalia.string.trim(content)
      end
      return nil
    end

    local function writeOption(opt, value)
      noctalia.writeFile(sysfs_base .. opt, value)
    end

    detect()

    if #available == 0 then
      barWidget.setText("No IdeaPad")
      barWidget.setTooltip("No IdeaPad sysfs nodes found")
    else
      local found = false
      for _, opt in ipairs(available) do
        if opt == default_option then
          current_option = default_option
          found = true
          break
        end
      end
      if not found then
        current_option = available[1]
      end
    end

    function update()
      if current_option == "" then return end
      noctalia.setUpdateInterval(5000)
      local val = readOption(current_option)
      if val then
        current_value = val
        barWidget.setGlyph(GLYPHS[current_option] or "laptop")
        if val == "1" then
          barWidget.setGlyphColor("primary", "normal")
          barWidget.setText(LABELS[current_option] .. " ON")
        else
          barWidget.setGlyphColor("disabled", "normal")
          barWidget.setText(LABELS[current_option] .. " OFF")
        end
        barWidget.setTooltip("Click to toggle " .. (LABELS[current_option] or current_option) .. "\nRight-click for all options")
      end
    end

    function onClick()
      if current_option == "" then return end
      local new_val = current_value == "1" and "0" or "1"
      writeOption(current_option, new_val)
      current_value = new_val
      update()
    end

    function onRightClick()
      noctalia.togglePanel("abhi/ideapad-controls:control")
    end
  '';

  environment.etc."noctalia/plugins/ideapad-controls/panel.luau".text = ''
    local OPTIONS = {"conservation_mode", "fan_mode", "fn_lock", "usb_charging"}
    local LABELS = {
      conservation_mode = "Conservation Mode",
      fan_mode = "Fan Mode",
      fn_lock = "Fn Lock",
      usb_charging = "USB Charging",
    }
    local GLYPHS = {
      conservation_mode = "battery-charging",
      fan_mode = "fan",
      fn_lock = "keyboard",
      usb_charging = "usb",
    }

    local sysfs_base = ""
    local available = {}
    local states = {}

    local function detect()
      local entries = noctalia.listDir("/sys/bus/platform/drivers/ideapad_acpi")
      if entries == nil then return end
      for _, entry in ipairs(entries) do
        if entry ~= "bind" and entry ~= "unbind" and entry ~= "module" and entry ~= "uevent" then
          local path = "/sys/bus/platform/drivers/ideapad_acpi/" .. entry .. "/"
          if noctalia.fileExists(path .. "conservation_mode") or noctalia.fileExists(path .. "fn_lock") then
            sysfs_base = path
            break
          end
        end
      end
      if sysfs_base == "" then return end
      for _, opt in ipairs(OPTIONS) do
        if noctalia.fileExists(sysfs_base .. opt) then
          table.insert(available, opt)
        end
      end
    end

    local function readOption(opt)
      local content = noctalia.readFile(sysfs_base .. opt)
      if content then
        return noctalia.string.trim(content)
      end
      return nil
    end

    local function writeOption(opt, value)
      noctalia.writeFile(sysfs_base .. opt, value)
    end

    local function refreshStates()
      for _, opt in ipairs(available) do
        local val = readOption(opt)
        states[opt] = val == "1"
      end
    end

    detect()

    local function buildTree()
      local header = {
        ui.label({ text = "IdeaPad Controls", fontSize = 16, fontWeight = "bold", color = "on_surface" }),
        ui.separator({}),
      }
      local rows = {}
      for _, opt in ipairs(available) do
        local label = LABELS[opt] or opt
        local isOn = states[opt] or false
        table.insert(rows, ui.row({ gap = 12, align = "center" }, {
          ui.label({ text = label, flexGrow = 1 }),
          ui.toggle({ checked = isOn, onChange = "toggle_" .. opt }),
        }))
      end
      local all = {}
      for _, h in ipairs(header) do
        table.insert(all, h)
      end
      for _, r in ipairs(rows) do
        table.insert(all, r)
      end
      return ui.column({ gap = 16 }, all)
    end

    function onOpen()
      refreshStates()
      panel.render(buildTree())
    end

    function toggle_conservation_mode(value)
      states["conservation_mode"] = value == "true"
      writeOption("conservation_mode", value == "true" and "1" or "0")
      panel.render(buildTree())
    end
    function toggle_fan_mode(value)
      states["fan_mode"] = value == "true"
      writeOption("fan_mode", value == "true" and "1" or "0")
      panel.render(buildTree())
    end
    function toggle_fn_lock(value)
      states["fn_lock"] = value == "true"
      writeOption("fn_lock", value == "true" and "1" or "0")
      panel.render(buildTree())
    end
    function toggle_usb_charging(value)
      states["usb_charging"] = value == "true"
      writeOption("usb_charging", value == "true" and "1" or "0")
      panel.render(buildTree())
    end

    function update()
      noctalia.setUpdateInterval(5000)
      if #available > 0 then
        refreshStates()
        panel.render(buildTree())
      end
    end
  '';

  environment.etc."noctalia/plugins/ideapad-controls/translations/en.json".text = ''
    {
      "settings.default_option.label": "Default option to display",
      "option.conservation_mode": "Conservation Mode",
      "option.fan_mode": "Fan Mode",
      "option.fn_lock": "Fn Lock",
      "option.usb_charging": "USB Charging"
    }
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
    mkdir -p /home/abhi/.local/share/noctalia/plugins/utc-clock/translations
    cp /etc/noctalia/plugins/utc-clock/plugin.toml /home/abhi/.local/share/noctalia/plugins/utc-clock/plugin.toml
    cp /etc/noctalia/plugins/utc-clock/clock.luau /home/abhi/.local/share/noctalia/plugins/utc-clock/clock.luau
    cp /etc/noctalia/plugins/utc-clock/translations/en.json /home/abhi/.local/share/noctalia/plugins/utc-clock/translations/en.json
    chown -R abhi:users /home/abhi/.local/share/noctalia/plugins/utc-clock

    mkdir -p /home/abhi/.local/share/noctalia/plugins/ideapad-controls/translations
    cp /etc/noctalia/plugins/ideapad-controls/plugin.toml /home/abhi/.local/share/noctalia/plugins/ideapad-controls/plugin.toml
    cp /etc/noctalia/plugins/ideapad-controls/widget.luau /home/abhi/.local/share/noctalia/plugins/ideapad-controls/widget.luau
    cp /etc/noctalia/plugins/ideapad-controls/panel.luau /home/abhi/.local/share/noctalia/plugins/ideapad-controls/panel.luau
    cp /etc/noctalia/plugins/ideapad-controls/translations/en.json /home/abhi/.local/share/noctalia/plugins/ideapad-controls/translations/en.json
    chown -R abhi:users /home/abhi/.local/share/noctalia/plugins/ideapad-controls
  '';

  system.activationScripts.mango-config.text = ''
    mkdir -p /home/abhi/.config/mango
    cp /etc/mango/config.conf /home/abhi/.config/mango/config.conf
    chown abhi:users /home/abhi/.config/mango/config.conf
  '';
}
