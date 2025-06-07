{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, fontconfig
, freetype
, icu
, libGL
, libinput
, wayland
, nix-update-script
, argonpkgs
, system
, ...
}:

let
  # Plukk ut Argon‐pakke‐settet for dette systemet
  argon = argonpkgs.packages.${system};
in stdenv.mkDerivation rec {
  pname    = "argonwm";
  version  = "0.1.1-1";

  src = fetchFromGitHub {
    owner  = "aCeTotal";
    repo   = "argon";
    rev    = "e1b19fdceb00acbaaa7be9b327d18aad8c931878";
    sha256 = "eCEgju2PA/qZmgmXxLcCOeqEzSMMtG7kknxkBa0ljkc=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libGL
    wayland
    libinput
    fontconfig
    freetype
    icu

    # Her bruker vi Argon‐utgaven av louvre i stedet for pkgs.louvre
    argon.louvre
  ];

  configurePhase = ''
    mkdir -p build
    meson setup --prefix=$out build .
  '';

  buildPhase = ''
    ninja -C build
  '';

  installPhase = ''
    ninja -C build install
  '';

  passthru = {
    updateScript = nix-update-script {};
  };

  meta = with lib; {
    description = "C++ Wayland compositor and Vulkan renderer";
    homepage    = "https://github.com/aCeTotal/argon";
    maintainers = [ maintainers.aCeTotal ];
    platforms   = platforms.linux;
  };
}

