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
  generic = {
    extraBuildInputs ? [ ],
    extraNativeBuildInputs ? [ ],
    patches ? [ ],
    postPatch ? "",
  }:
  stdenv.mkDerivation (finalAttrs: {
    pname = "wlroots_vk";
    version = "0.1.0";

    src = fetchFromGitHub {
      owner = "aCeTotal";
      repo = "wlroots_vk";
      rev = "243b15cf3512e0cf8e87796d11d4583332a75bac";
      sha256 = "sha256-I8z50yA/ukvXEC5TksG84+GrQpfC4drBJDRGw0R8RLk=";
    };

    inherit patches postPatch;

    outputs = [ "out" "examples" ];

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

    buildInputs = [
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
    ++ lib.optional enableXWayland xwayland
    ++ extraBuildInputs;

    mesonFlags = lib.optional (!enableXWayland) "-Dxwayland=disabled";

    postFixup = ''
      mkdir -p $examples/bin
      cd ./examples
      for binary in $(find . -executable -type f -printf '%P\n' | grep -vE '\.so'); do
        cp "$binary" "$examples/bin/wlroots-$binary"
      done
    '';

    passthru.tests = {
      tinywl = nixosTests.tinywl;
      pkg-config = testers.hasPkgConfigModules {
        package = finalAttrs.finalPackage;
      };
    };

    meta = {
      description = "Modular Wayland compositor library with Vulkan modifications";
      longDescription = ''
        Pluggable, composable, unopinionated modules for building a Wayland
        compositor; or about 50,000 lines of code you were going to write anyway.
      '';
      homepage = "https://github.com/aCeTotal/wlroots_vk";
      changelog = "https://github.com/aCeTotal/wlroots_vk/commit/${finalAttrs.version}";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      maintainers = with lib.maintainers; [ ];
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
{
  wlroots_vk = generic {
    extraBuildInputs = [ lcms2 ];
  };
}

