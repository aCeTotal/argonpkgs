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
, louvre           # ← din lokale Louvre-derivasjon
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname    = "argon";
  version  = "0.1.1-1";

  src = fetchFromGitHub {
    owner = "aCeTotal";
    repo  = "argon";
    rev   = "e1b19fdceb00acbaaa7be9b327d18aad8c931878";
    sha256 = "eCEgju2PA/qZmgmXxLcCOeqEzSMMtG7kknxkBa0ljkc=";
  };

  # Meson, Ninja og pkg-config må være tilgjengelig under bygg
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
    louvre
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

  meta = {
    description = "C++ Wayland compositor and Vulkan renderer";
    homepage    = "https://github.com/aCeTotal/argon";
    mainProgram = "argon";
    maintainers = [ lib.maintainers.aCeTotal ];
    platforms   = lib.platforms.linux;
  };
}


