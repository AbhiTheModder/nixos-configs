# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  pkgsUnstable,
  inputs,
  ...
}:

let
  fixPythonPkg = inputs.fix-python.packages.${pkgs.stdenv.hostPlatform.system}.default;
  zenBrowser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    config.zen.policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisableFirefoxAccounts = true;
    };
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix = {
    settings = {
      max-jobs = 8;
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "btw"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.resolvconf.enable = true;
  networking.resolvconf.useLocalResolver = true;
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53; # Port for incoming DNS Queries.
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query"
      ];
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
      #Enable Blocking of certain domains.
      blocking = {
        denylists = {
          #Adblocking
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardDNS.txt"
            "https://adaway.org/hosts.txt"
            "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=1&mimetype=plaintext"
          ];
          #Another filter for blocking adult sites
          adult = [ "https://blocklistproject.github.io/Lists/porn.txt" ];
          #You can add additional categories
        };
        #Configure what block categories are used
        clientGroupsBlock = {
          default = [ "ads" ];
          kids-ipad = [
            "ads"
            "adult"
          ];
        };
      };
    };
  };

  # Enable KVM
  virtualisation.virtualbox.host.enableKvm = true;
  virtualisation.libvirtd.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = with pkgs; [ xterm ];

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-apps.enable = false;

  # Environment variables
  environment.sessionVariables = rec {
    ANDROID_HOME = "$HOME/Android/Sdk";
    NIXOS_OZONE_WL = "1";
    PATH = [
      "$HOME/Android/flutter/bin"
      "${ANDROID_HOME}/platform-tools"
      "${ANDROID_HOME}/build-tools/36.0.0"
      "${ANDROID_HOME}/cmdline-tools/latest/bin"
    ];
  };

  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-elan;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
    virtualbox = {
      host.enable = true;
      host.addNetworkInterface = false;
      guest.clipboard = true;
      guest.dragAndDrop = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.abhi = {
    isNormalUser = true;
    description = "Abhi";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
    ];
    packages = with pkgs; [
      pkgsUnstable.telegram-desktop
    ];
  };

  # Install programs
  programs.ghidra.enable = true;
  programs.xonsh = {
    enable = true;
    extraPackages = ps: with ps; [ pip ];
  };
  programs.bash = {
    blesh.enable = true;
    shellAliases = {
      cd = "z";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#abhi";
      reboot = "sudo reboot";
      cat = "bat";
      vi = "hx";
      ls = "eza --icons";
      ".." = "cd ..";
      ":q" = "exit";
      wget = "wget -q --show-progress";
      jjar = "java -jar";
    };
    promptInit = ''
      	  PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'; PS1='\[\e[38;5;39m\] \[\e[0m\]\[\e[38;5;46m\]┬─[\[\e[38;5;226m\]\u\[\e[0m\]@\[\e[38;5;33m\]\h\[\e[0m\]:\w\[\e[38;5;46m\]]─[\[\e[38;5;46m\]''${PS1_CMD1}]\n\[\e[38;5;46m\]╰─>\[\e[0m\] '
      	'';
    shellInit = ''
        	  eval "$(direnv hook bash)"
        	  _ZO_DOCTOR=0
        	  # Wasmer
      	  export WASMER_DIR="/home/abhi/.wasmer"
      	  [ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"
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
    direnvrcExtra = "";
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
      obs-vaapi # optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
      obs-advanced-masks
      droidcam-obs
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    inputs.ida-pro-overlay.overlays.default
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
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
    android-studio
    distrobox
    eza
    bun
    vlc
    helix
    wl-clipboard
    delta
    pkgsUnstable.nixd
    nixfmt-rfc-style
    croc
    kdePackages.kdenlive
    showmethekey
    axel
    ripgrep

    pkgsUnstable.ty
    pkgsUnstable.ruff

    # rev
    (callPackage ida-pro {
      # Alternatively, fetch the installer through `fetchurl`, use a local path, etc.
      runfile = fetchurl {
        url = "https://pintobyte.com/tmp/ida-pro_91_x64linux.run";
        hash = "sha256-j/CAIr46DvaTqePqAQENE1aybP3Lvn/daNAbPJcA+eI=";
      };
    })
    pkgsUnstable.radare2
    cutter
    iaito
    jadx
    frida-tools
    burpsuite
    imhex

    # Cursor
    apple-cursor

    # GNOME APPS
    nautilus
    gnome-calculator
    blackbox-terminal
    gnome-disk-utility
    gnome-tweaks
    gnome-console
    gnome-text-editor
    gnome-system-monitor
    fragments
    switcheroo
    resources
    loupe
    decibels

    # GNOME EXTENSIONS
    gnomeExtensions.focus
    gnomeExtensions.vitals
    gnomeExtensions.app-hider
    # gnomeExtensions.app-menu-is-back
    gnomeExtensions.arcmenu
    # gnomeExtensions.auto-adwaita-colors
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.color-picker
    gnomeExtensions.compact-top-bar
    gnomeExtensions.compiz-windows-effect
    # gnomeExtensions.dash2dock-lite
    gnomeExtensions.desktop-cube
    gnomeExtensions.do-not-disturb-while-screen-sharing-or-recording
    gnomeExtensions.ideapad-controls
    gnomeExtensions.open-bar
    gnomeExtensions.emoji-copy
    gnomeExtensions.appindicator
    gnomeExtensions.tiling-shell

    # OTHER
    peazip
    proton-pass
    handbrake
    pkgsUnstable.opencode
    pkgsUnstable.zed-editor-fhs
    zenBrowser

    # Python
    python3
    python3Packages.pip
  ];

  fonts.packages = with pkgs; [
    maple-mono.NF-CN
    noto-fonts-color-emoji
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
