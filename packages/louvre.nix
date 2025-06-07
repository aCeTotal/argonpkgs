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
  pname = "louvreVK";
  version = "2.18.2-1";

  src = fetchFromGitHub {
    owner = "aCeTotal";
    repo = "Louvre";
    rev = "4d53f14";
    hash = "sha256-ZdV/KvYnPN4IKU6kbjDhCgcC3TdWqZbNJzDt39ZQ2x8=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  postPatch = ''
    substituteInPlace examples/meson.build \
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
    description = "C++ library for building Wayland compositors";
    homepage = "https://github.com/CuarzoSoftware/Louvre";
    mainProgram = "louvre";
    maintainers = [ lib.maintainers.x ];
    platforms = lib.platforms.linux;
  };
})


