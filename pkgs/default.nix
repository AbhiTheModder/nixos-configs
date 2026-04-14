{
  inputs,
  system,
  ...
}:
final: prev:

let
  pkgs = prev;
  kisesi = import ./kisesi.nix { inherit pkgs; };
  mechvibes-lite = import ./mechvibes-lite.nix { inherit pkgs kisesi; };
  zen-browser = import ./zen-browser.nix { inherit inputs system; };
  fix-python = inputs.fix-python.packages.${system}.default;
  iaito = pkgs.callPackage ./iaito.nix { };
in
{
  kisesi = kisesi;
  mechvibes-lite = mechvibes-lite;
  zen-browser = zen-browser;
  fixPythonPkg = fix-python;
  iaito = iaito;
}
