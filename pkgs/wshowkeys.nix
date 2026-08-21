{
  stdenv,
  meson,
  ninja,
  pkg-config,
  wayland-scanner,
  wayland-protocols,
  wayland,
  cairo,
  libinput,
  pango,
  systemd,
  libxkbcommon,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "wshowkeys";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DreamMaoMao";
    repo = "wshowkeys";
    rev = "35d70762ab9af4ea301853e79b3b925d5fe9e920";
    hash = "sha256-8upkB3179A8wP5Hph0EanE0VuIxe7VsmsqzcRaOq5y0=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland-protocols
    wayland
    cairo
    libinput
    pango
    systemd
    libxkbcommon
  ];

  mesonFlags = [
    "-Ddevpath=/dev/input/"
  ];

  meta = {
    description = "Show keys on screen on Wayland (mango fork)";
    mainProgram = "wshowkeys";
  };
}