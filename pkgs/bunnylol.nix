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
    rev = "6dd85e0d8bac26d173cb98ded564a3e7e2fbe91f";
    hash = "sha256-wqVF0y0oJbWKABOu3hY/Yl/MFilDloci30kFKEQnTKs=";
  };

  cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  buildFeatures = [ "server" "cli" ];

  meta = {
    description = "Smart bookmark server and CLI: URL shortcuts for your browser's search bar and terminal";
    homepage = "https://github.com/facebook/bunnylol.rs";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "bunnylol";
  };
}
