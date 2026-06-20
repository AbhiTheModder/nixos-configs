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
    rev = "184f55dbc5320c34a56d02353410ad35a0f3e090";
    hash = "sha256-N8V6CkCmTlw0rWmDXiKI1Z4YS7T7fWCr9aPRk5OpGHs=";
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