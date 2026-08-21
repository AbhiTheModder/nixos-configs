{ fetchFromGitHub, lib, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "leaf";
  version = "1.28.0";

  src = fetchFromGitHub {
    owner = "RivoLink";
    repo = "leaf";
    rev = version;
    hash = "sha256-eCSGZ+fBc1fxVBQdZgpZYkop2mO1mVPDylXIVK/C2JE=";
  };

  cargoHash = "sha256-B0hYSG00C3my2TcGE+rfziTW9r3HZH+8MAHFQq6uiIk=";

  meta = {
    description = "A friendly terminal Markdown previewer";
    homepage = "https://github.com/RivoLink/leaf";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "leaf";
  };
}
