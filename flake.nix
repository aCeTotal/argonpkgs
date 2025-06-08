{
  description = "argonpkgs – mine lokale derivations";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgFiles = builtins.attrNames (builtins.readDir ./packages);

        myOverlay = final: prev:
          builtins.listToAttrs (
            map (file:
              let
                name = builtins.replaceStrings [".nix"] ["" ] file;
                drv  = final.callPackage ./packages/${file} {};
              in {
                inherit name;
                value = drv;
              }
            ) pkgFiles
          );

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ myOverlay ];
        };

        pkgSet = builtins.listToAttrs (
          map (file:
            let name = builtins.replaceStrings [".nix"] ["" ] file;
            in { inherit name; value = pkgs.${name}; }
          ) pkgFiles
        );
      in
      {
        packages = pkgSet;
      }
    );
}

