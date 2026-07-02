{
  lib,
  stdenv,
  buildGo126Module,
  fetchFromGitHub,
  installShellFiles,
  writableTmpDirAsHomeHook,
}:

buildGo126Module (finalAttrs: {
  pname = "crush";
  version = "0.81.0";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "crush";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FOvkCQxDW1dipzIzgQz2uvHIv6bm/TVV1WwhrvmBDWg=";
  };

  vendorHash = "sha256-4gHvyEqiFhEvZ90lJbXeI/1fMMo6L19P/PD5Eu5YUmI=";

  ldflags = [
    "-s"
    "-X=github.com/charmbracelet/crush/internal/version.Version=${finalAttrs.version}"
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  __darwinAllowLocalNetworking = true;

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd crush \
      --bash <($out/bin/crush completion bash) \
      --fish <($out/bin/crush completion fish) \
      --zsh <($out/bin/crush completion zsh)
  '';

  meta = {
    description = "Glamourous AI coding agent for your favourite terminal";
    homepage = "https://github.com/charmbracelet/crush";
    license = lib.licenses.fsl11Mit;
    mainProgram = "crush";
    platforms = lib.platforms.linux;
  };
})
