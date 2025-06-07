{
  description = "argonpkgs – just some derivations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];
      pkgFiles = builtins.attrNames (builtins.readDir ./packages);
    in
    {
      packages = builtins.listToAttrs (map (system: {
        name = system;
        value = let
          pkgs = import nixpkgs { inherit system; };
        in
          builtins.listToAttrs (map (file: {
            name  = builtins.replaceStrings [ ".nix" ] [ "" ] file;
            value = import ./packages/${file} { inherit pkgs; };
          }) pkgFiles);
      }) systems);
    };
}

