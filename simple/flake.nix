{
  description = "An example of flake.nix to streamliine development toolchains";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    modern-nix.url = "github:DrSensor/modern-nix-templates";
  };

  outputs = { self, nixpkgs, flake-utils, modern-nix, ... }@inputs:
    let
      inherit (flake-utils.lib) simpleFlake defaultSystems allSystems;
      inherit (modern-nix.no-self) overlayFrom;
    in
      simpleFlake {
        inherit self nixpkgs;
        name = "hello"; # map to package in nixpkgs+overlay+preOverlays

        shell = { pkgs }: with pkgs; mkShell {
          packages = [];
          inputsFrom = [];
        };

        systems = [
          #https://github.com/NixOS/nixpkgs/blob/master/lib/systems/doubles.nix
        ] ++ defaultSystems;

        overlay = final: prev: {};
        preOverlays = overlayFrom inputs;
      };
}
