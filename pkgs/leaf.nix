{ fetchFromGitHub, lib, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "leaf";
  version = "1.26.0";

  src = fetchFromGitHub {
    owner = "RivoLink";
    repo = "leaf";
    rev = version;
    hash = "sha256-/tMlInOT7ipqZ3ONE70QgmPUw9nDC5+7vgdpCyXqr2E=";
  };

  cargoHash = "sha256-JXmyjeEBi8Ej8TBLD7Nwq+k8SYwR2LTwFgdBwjc6nzU=";

  meta = {
    description = "A friendly terminal Markdown previewer";
    homepage = "https://github.com/RivoLink/leaf";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "leaf";
  };
}