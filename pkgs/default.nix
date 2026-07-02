{
  inputs,
  system,
  ...
}:
final: prev:

let
  pkgs = prev;
  kisesi = import ./kisesi.nix { inherit pkgs; };
  mechvibes-lite = import ./mechvibes-lite.nix { inherit pkgs kisesi; };
  zen-browser = import ./zen-browser.nix { inherit inputs system; };
  fix-python = inputs.fix-python.packages.${system}.default;
  iaito = pkgs.callPackage ./iaito.nix { radare2 = final.radare2; };
  claude-code = pkgs.callPackage ./claude-code.nix { };
  bunnylol = pkgs.callPackage ./bunnylol.nix { };
  wshowkeys = pkgs.callPackage ./wshowkeys.nix { };
  go_1_26_4 = pkgs.callPackage ./go_1_26_4.nix { };
  buildGo126_4Module = pkgs.callPackage (
    "${pkgs.path}/pkgs/build-support/go/module.nix"
  ) { go = go_1_26_4; };
  crush = pkgs.callPackage ./crush.nix { buildGo126Module = buildGo126_4Module; };

  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "39aaf6dc77e546fe7f7836f102a6c57f96d15365";
    hash = "sha256-rl8EA8aymVQU1296IVsEZ2WR9xBxQTYBK+VUCic/K3k=";
  };

  ouch-plugin = pkgs.fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "406ce6c13ec3a18d4872b8f64b62f4a530759b2c";
    hash = "sha256-UHneVJ+YXyDuPrZS+PZbs9n9h+VN5M2QG36FdprBkJc=";
  };

  gvfs-plugin = pkgs.fetchFromGitHub {
    owner = "boydaihungst";
    repo = "gvfs.yazi";
    rev = "3abc0a258f9d7aeaa453a2d0d6e103c5a305953d";
    hash = "sha256-UHneVJ+YXyDuPrZS+PZbs9n9h+VN5M2QG36FdprBkJc=";
  };

  yazi = prev.yazi.override {
    _7zz = pkgs._7zz-rar;
    plugins = {
      "git.yazi" = "${yazi-plugins}/git.yazi";
      "smart-paste.yazi" = "${yazi-plugins}/smart-paste.yazi";
      "diff.yazi" = "${yazi-plugins}/diff.yazi";
      "mount.yazi" = "${yazi-plugins}/mount.yazi";
      "toggle-pane.yazi" = "${yazi-plugins}/toggle-pane.yazi";
      "zoom.yazi" = "${yazi-plugins}/zoom.yazi";
      "mime-ext.yazi" = "${yazi-plugins}/mime-ext.yazi";
      "chmod.yazi" = "${yazi-plugins}/chmod.yazi";
      "ouch.yazi" = "${ouch-plugin}";
      "gvfs.yazi" = "${gvfs-plugin}";
    };
    initLua = pkgs.writeText "yazi-init.lua" ''
      require("git"):setup {
        order = 1500,
      }
      require("gvfs"):setup({})

      function Linemode:size_and_mtime()
        local time = math.floor(self._file.cha.mtime or 0)
        if time == 0 then
          time = ""
        elseif os.date("%Y", time) == os.date("%Y") then
          time = os.date("%b %d %H:%M", time)
        else
          time = os.date("%b %d  %Y", time)
        end

        local size = self._file:size()
        return string.format("%s %s", size and ya.readable_size(size) or "-", time)
      end
    '';
    settings = {
      yazi = {
        mgr = {
          linemode = "size_and_mtime";
        };
        plugin = {
          prepend_fetchers = [
            { id = "git"; url = "*"; run = "git"; group = "git"; }
            { id = "git"; url = "*/"; run = "git"; group = "git"; }
            { id = "mime"; url = "local://*"; run = "mime-ext.local"; prio = "high"; group = "mime"; }
            { id = "mime"; url = "remote://*"; run = "mime-ext.remote"; prio = "high"; group = "mime"; }
          ];
          prepend_previewers = [
            { mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}"; run = "ouch"; }
            { url = "/run/user/1000/gvfs/**/*"; run = "noop"; }
            { url = "/run/media/abhi/**/*"; run = "noop"; }
          ];
          prepend_preloaders = [
            { url = "/run/user/1000/gvfs/**/*"; run = "noop"; }
            { url = "/run/media/abhi/**/*"; run = "noop"; }
          ];
        };
      };
      keymap = {
        mgr.prepend_keymap = [
          { on = "p"; run = "plugin smart-paste"; desc = "Paste into hovered dir or CWD"; }
          { on = "<C-d>"; run = "plugin diff"; desc = "Diff selected with hovered file"; }
          { on = [ "M" "m" ]; run = "plugin mount"; desc = "Mount manager (udisks)"; }
          { on = [ "M" "M" ]; run = "plugin gvfs -- select-then-mount --jump"; desc = "Mount device and jump to it (gvfs)"; }
          { on = [ "M" "u" ]; run = "plugin gvfs -- select-then-unmount --eject"; desc = "Unmount/eject device (gvfs)"; }
          { on = [ "M" "a" ]; run = "plugin gvfs -- add-mount"; desc = "Add GVFS mount URI"; }
          { on = [ "g" "m" ]; run = "plugin gvfs -- jump-to-device"; desc = "Jump to mounted device"; }
          { on = "T"; run = "plugin toggle-pane max-preview"; desc = "Maximize or restore preview pane"; }
          { on = "+"; run = "plugin zoom 1"; desc = "Zoom in hovered file"; }
          { on = "-"; run = "plugin zoom -1"; desc = "Zoom out hovered file"; }
          { on = [ "c" "m" ]; run = "plugin chmod"; desc = "Chmod on selected files"; }
          { on = "<C-n>"; run = "shell --orphan -- ripdrag %s -x"; desc = "Drag and drop selected files"; }
          { on = "C"; run = "plugin ouch"; desc = "Compress with ouch"; }
        ];
      };
    };
  };
in
{
  kisesi = kisesi;
  mechvibes-lite = mechvibes-lite;
  zen-browser = zen-browser;
  fixPythonPkg = fix-python;
  iaito = iaito;
  claude-code = claude-code;
  bunnylol = bunnylol;
  wshowkeys = wshowkeys;
  crush = crush;
  yazi = yazi;
}
