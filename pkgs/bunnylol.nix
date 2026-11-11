{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "bunnylol";
  version = "0.1.2-unstable-2025-04-14";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "bunnylol.rs";
    rev = "d628fb037f37596204efce663b8023a44b01c6fa";
    hash = "sha256-0vPdLDe4xvkL28kXI2fChjqdwa9iAGS6o53SX4a6kB8=";
  };

  cargoHash = "sha256-+BxfDyx6UZBEx95ZeV7T5fqtwXKyt5MiWDBKDq2UXg0=";

  buildFeatures = [ "server" "cli" ];

  meta = {
    description = "Smart bookmark server and CLI: URL shortcuts for your browser's search bar and terminal";
    homepage = "https://github.com/facebook/bunnylol.rs";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "bunnylol";
  };
}
