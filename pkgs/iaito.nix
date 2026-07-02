{
  fetchFromGitHub,
  lib,
  meson,
  ninja,
  pkg-config,
  python3,
  qt6Packages,
  radare2,
  stdenv,
  symlinkJoin,
  makeWrapper,
}@args:
let
  unwrapped = stdenv.mkDerivation (finalAttrs: {
    pname = "iaito-unwrapped";
    version = "6.1.8";

    srcs = [
      (fetchFromGitHub {
        owner = "radareorg";
        repo = "iaito";
        rev = "fb1b22c35f0b4aabd409becd2d5502179e5b85e4";
        hash = "sha256-aIJSfr5ZH1Naky66x85C5Y3Ix7sDzoYK84l+oA7Wggs=";
        name = "main";
      })
      (fetchFromGitHub {
        owner = "radareorg";
        repo = "iaito-translations";
        rev = "e66b3a962a7fc7dfd730764180011ecffbb206bf";
        hash = "sha256-6NRTZ/ydypsB5TwbivvwOH9TEMAff/LH69hCXTvMPp8=";
        name = "translations";
      })
    ];
    sourceRoot = "main/src";

    postUnpack = ''
      chmod -R u+w translations
    '';

    postPatch = ''
      substituteInPlace common/ResourcePaths.cpp \
        --replace-fail "/app/share/iaito/translations" "$out/share/iaito/translations"
    '';

    nativeBuildInputs = [
      meson
      ninja
      pkg-config
      python3
      qt6Packages.qttools
      qt6Packages.wrapQtAppsHook
    ];

    buildInputs = [
      qt6Packages.qtbase
      radare2
    ];

    propagatedBuildInputs = [
      radare2
    ];

    mesonFlags = [
      (lib.mesonBool "with_qt6" true)
    ];

    postBuild = ''
      pushd ../../../translations
      make build -j $NIX_BUILD_CORES PREFIX=$out
      popd
    '';

    installPhase = ''
      runHook preInstall

      install -m755 -Dt $out/bin iaito
      install -m644 -Dt $out/share/metainfo ../org.radare.iaito.appdata.xml
      install -m644 -Dt $out/share/applications ../org.radare.iaito.desktop
      install -m644 -Dt $out/share/icons/hicolor/scalable/apps ../img/org.radare.iaito.svg

      pushd ../../../translations
      make install -j$NIX_BUILD_CORES PREFIX=$out
      popd

      runHook postInstall
    '';

    meta = {
      description = "Official radare2 GUI";
      homepage = "https://radare.org/n/iaito.html";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
      mainProgram = "iaito";
    };
  });

  r2Prefix = symlinkJoin {
    name = "iaito-r2env";
    paths = [
      radare2
      unwrapped
    ];
  };
in
stdenv.mkDerivation {
  pname = "iaito";
  version = unwrapped.version;

  nativeBuildInputs = [
    makeWrapper
    qt6Packages.wrapQtAppsHook
  ];
  buildInputs = [
    radare2
    qt6Packages.qtbase
  ];

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin $out/share

    makeWrapper ${r2Prefix}/bin/iaito $out/bin/iaito \
      --prefix PATH : "${r2Prefix}/bin" \
      --set R2_PREFIX ${r2Prefix}

    for prog in r2pm radare2 rabin2 r2; do
      if [ -x ${r2Prefix}/bin/$prog ]; then
        makeWrapper ${r2Prefix}/bin/$prog $out/bin/$prog \
          --set R2_PREFIX ${r2Prefix}
      fi
    done

    ln -s ${unwrapped}/share/applications $out/share/applications 2>/dev/null || true
    ln -s ${unwrapped}/share/metainfo $out/share/metainfo 2>/dev/null || true
    ln -s ${unwrapped}/share/icons $out/share/icons 2>/dev/null || true
    ln -s ${unwrapped}/share/iaito $out/share/iaito

    ln -s ${r2Prefix}/lib $out/lib
  '';

  meta = unwrapped.meta // {
    description = "Official radare2 GUI (with r2pm support)";
  };
}
