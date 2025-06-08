{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  fontconfig,
  icu,
  libdrm,
  libGL,
  libinput,
  libX11,
  libXcursor,
  libxkbcommon,
  libgbm,
  pixman,
  seatd,
  srm-cuarzo,
  udev,
  wayland,
  xorgproto,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "argonWM";
  version = "0.1.0-0";

  src = fetchFromGitHub {
    owner = "aCeTotal";
    repo = "argon";
    rev = "b41b90fea9ef755fd9ceab5273e4356809d722b1";
    hash = "sha256-Cvp31EgJ4Z+0dhXybnYdNyISAe6rsep79qPzR893tCM=";
  };

  sourceRoot = "${finalAttrs.src.name}/";

  postPatch = ''
    substituteInPlace tiling/meson.build \
      --replace-fail "/usr/local/share/wayland-sessions" "${placeholder "out"}/share/wayland-sessions"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    fontconfig
    icu
    libdrm
    libGL
    libinput
    libX11
    libXcursor
    libxkbcommon
    libgbm
    pixman
    seatd
    srm-cuarzo
    udev
    wayland
    xorgproto
  ];

  outputs = [
    "out"
    "dev"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "C++ Wayland tiling";
    homepage = "https://github.com/aCeTotal/argon";
    mainProgram = "argon";
    maintainers = [ lib.maintainers.x ];
    platforms = lib.platforms.linux;
  };
})


