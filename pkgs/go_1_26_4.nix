{
  lib,
  stdenv,
  fetchurl,
}:

let
  version = "1.26.4";
  hashes = {
    linux-amd64 = "sha256-EVPT1Q4Kx2S0R63+BcK88I6InUKgLg/gJZvUf2czrX8=";
  };
  platform = with stdenv.hostPlatform.go; "${GOOS}-${if GOARCH == "arm" then "armv6l" else GOARCH}";
in
stdenv.mkDerivation {
  name = "go-${version}";

  src = fetchurl {
    url = "https://go.dev/dl/go${version}.${platform}.tar.gz";
    hash = hashes.${platform} or (throw "Missing Go hash for platform ${platform}");
  };

  dontStrip = stdenv.hostPlatform.isDarwin;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/go $out/bin
    cp -r . $out/share/go
    ln -s $out/share/go/bin/go $out/bin/go
    ln -s $out/share/go/bin/gofmt $out/bin/gofmt
    runHook postInstall
  '';

  env = {
    inherit (stdenv.targetPlatform.go) GOOS GOARCH;
    CGO_ENABLED = 1;
  };

  __structuredAttrs = true;

  meta = {
    description = "Go Programming language ${version} (binary)";
    homepage = "https://go.dev/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "go";
  };
}