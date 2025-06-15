{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  meson,
  ninja,
  pkg-config,
  wayland-scanner,
  libGL,
  wayland,
  wayland-protocols,
  libinput,
  libxkbcommon,
  pixman,
  libcap,
  libgbm,
  xorg,
  hwdata,
  seatd,
  vulkan-loader,
  glslang,
  libliftoff,
  libdisplay-info,
  lcms2,
  nixosTests,
  testers,

  enableXWayland ? true,
  xwayland ? null,
}:

let
  generic =
    {
      version,
      hash,
      extraBuildInputs ? [ ],
      extraNativeBuildInputs ? [ ],
      patches ? [ ],
      postPatch ? "",
    }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "wlroots";
      inherit version;

      inherit enableXWayland;

      src = fetchFromGitHub {
        owner = "aCeTotal";
        repo = "wlroots_vk";
        rev = finalAttrs.version;
        inherit hash;
      };

      inherit patches postPatch;

      # $out for the library and $examples for the example programs (in examples):
      outputs = [
        "out"
        "examples"
      ];

      strictDeps = true;
      depsBuildBuild = [ pkg-config ];

      nativeBuildInputs = [
        meson
        ninja
        pkg-config
        wayland-scanner
        glslang
        hwdata
      ] ++ extraNativeBuildInputs;

      buildInputs =
        [
          libliftoff
          libdisplay-info
          libGL
          libcap
          libinput
          libxkbcommon
          libgbm
          pixman
          seatd
          vulkan-loader
          wayland
          wayland-protocols
          xorg.libX11
          xorg.xcbutilerrors
          xorg.xcbutilimage
          xorg.xcbutilrenderutil
          xorg.xcbutilwm
        ]
        ++ lib.optional finalAttrs.enableXWayland xwayland
        ++ extraBuildInputs;

      mesonFlags = lib.optional (!finalAttrs.enableXWayland) "-Dxwayland=disabled";

      postFixup = ''
        # Install ALL example programs to $examples:
        # screencopy dmabuf-capture input-inhibitor layer-shell idle-inhibit idle
        # screenshot output-layout multi-pointer rotation tablet touch pointer
        # simple
        mkdir -p $examples/bin
        cd ./examples
        for binary in $(find . -executable -type f -printf '%P\n' | grep -vE '\.so'); do
          cp "$binary" "$examples/bin/wlroots-$binary"
        done
      '';

      # Test via TinyWL (the "minimum viable product" Wayland compositor based on wlroots):
      passthru.tests = {
        tinywl = nixosTests.tinywl;
        pkg-config = testers.hasPkgConfigModules {
          package = finalAttrs.finalPackage;
        };
      };

      meta = {
        description = "Modular Wayland compositor library";
        longDescription = ''
          Pluggable, composable, unopinionated modules for building a Wayland
          compositor; or about 50,000 lines of code you were going to write anyway.
        '';
        inherit (finalAttrs.src.meta) homepage;
        changelog = "https://gitlab.freedesktop.org/wlroots/wlroots/-/tags/${version}";
        license = lib.licenses.mit;
        platforms = lib.platforms.linux;
        maintainers = with lib.maintainers; [
          primeos
          synthetica
          rewine
        ];
        pkgConfigModules = [
          (
            if lib.versionOlder finalAttrs.version "0.18" then
              "wlroots"
            else
              "wlroots-${lib.versions.majorMinor finalAttrs.version}"
          )
        ];
      };
    });

in
rec {
  wlroots_0_1 = generic {
    version = "0.1.0";
    hash = "sha256-I8z50yA/ukvXEC5TksG84+GrQpfC4drBJDRGw0R8RLk=";
    extraBuildInputs = [
      lcms2
    ];
  };
}
