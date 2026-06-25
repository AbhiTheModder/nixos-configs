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
  version = "0.79.1-nightly-${builtins.substring 0 9 finalAttrs.src.rev}";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "crush";
    rev = "6f8b104d4de8b94638850ba99935e75b32d7812a";
    hash = "sha256-wd6E2CrOJQa2A38+ecgQfwhJrjcL8Acgl5JtuW3Yu+s=";
  };

  vendorHash = "sha256-bkKcNkYNOIHCkK752zuqEFhfrLE2AraD2xQKgPZpHSw=";

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