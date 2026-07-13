{ ... }:

{
  environment.sessionVariables = rec {
    ANDROID_HOME = "$HOME/Android/Sdk";
    NIXOS_OZONE_WL = "1";
    PODMAN_COMPOSE_WARNING_LOGS = "false";
    WASMER_DIR = "/home/abhi/.wasmer";
    WASMER_CACHE_DIR = "$WASMER_DIR/cache";
    PATH = [
      "$HOME/Android/flutter/bin"
      "$HOME/.local/bin"
      "${ANDROID_HOME}/platform-tools"
      "${ANDROID_HOME}/build-tools/36.1.0"
      "${ANDROID_HOME}/cmdline-tools/latest/bin"
      "$HOME/.opencode/bin"
      "$HOME/.pub-cache/bin"
      "$WASMER_DIR/bin"
    ];
  };

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
    LADSPA_PATH = "/run/current-system/sw/lib/ladspa";
    _ZO_DOCTOR = "0";
  };

  programs.bash.interactiveShellInit = ''
    nbv() { leaf "$(nb show "$1" --path)"; }
  '';
}
