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
  radare2 = pkgs.callPackage ./radare2.nix { };
  iaito = pkgs.callPackage ./iaito.nix { inherit radare2; };
  bunnylol = pkgs.callPackage ./bunnylol.nix { };
  wshowkeys = pkgs.callPackage ./wshowkeys.nix { };
in
{
  kisesi = kisesi;
  mechvibes-lite = mechvibes-lite;
  zen-browser = zen-browser;
  fixPythonPkg = fix-python;
  radare2 = radare2;
  iaito = iaito;
  bunnylol = bunnylol;
  wshowkeys = wshowkeys;
}
