{
  description = "argonpkgs – mine lokale derivations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import pkgs with overlay
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };

        # Get all package files from ./packages/*.nix
        pkgFiles = builtins.filter (f: f != "default.nix")
          (builtins.attrNames (builtins.readDir ./packages));

        # Turn them into a package set
        packageSet = builtins.listToAttrs (map (file:
          let
            name = builtins.replaceStrings [".nix"] [""] file;
          in {
            inherit name;
            value = pkgs.callPackage ./packages/${file} {};
          }
        ) pkgFiles);

      in {
        packages = packageSet;

        # Dev shell with all packages in scope
        devShell = pkgs.mkShell {
          packages = builtins.attrValues packageSet;
        };
      }
    );

  overlays.default = final: prev:
    let
      pkgFiles = builtins.filter (f: f != "default.nix")
        (builtins.attrNames (builtins.readDir ./packages));
    in
    builtins.listToAttrs (map (file:
      let
        name = builtins.replaceStrings [".nix"] [""] file;
        drv = final.callPackage ./packages/${file} {};
      in {
        inherit name;
        value = drv;
      }
    ) pkgFiles);
}

