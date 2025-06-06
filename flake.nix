{
  description = "argonpkgs - just some derivations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
  let
    systems = [ "x86_64-linux" ];

    overlay = final: prev: let
      allPackages = 
        builtins.listToAttrs (map (file: {
          name  = builtins.replaceStrings [ ".nix" ] [ "" ] (builtins.baseNameOf file);
          value = prev.callPackage (./packages/${builtins.baseNameOf file}) {};
        }) (builtins.attrNames (builtins.readDir ./packages)));
    in

    {
      inherit allPackages;
    };
  in
  {
    overlays = [ overlay ];

    packages = builtins.listToAttrs (map (system: {
      name  = system;
      value = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };
    }) systems);
  };
}

