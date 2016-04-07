{ stdenv
, fetchurl
, python3
, yasm

, glib
, gst-plugins-bad
, gst-plugins-base
, gstreamer
, libdrm
, libva
, libvpx
, mesa
, systemd_lib
, wayland
, xorg
}:

let
  inherit (stdenv.lib)
    enFlag
    optionalString;
in

stdenv.mkDerivation rec {
  name = "gstreamer-vaapi-1.8.0";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/gstreamer-vaapi/"
        + "${name}.tar.xz";
    sha256Url = "${url}.sha256sum";
    sha256 = "3b83d405f4423ab0bdc8fbe25e72c4c37b59b7776da21f1d49b0444957595ac1";
  };

  nativeBuildInputs = [
    python3
    yasm
  ];

  buildInputs = [
    glib
    gstreamer
    gst-plugins-bad
    gst-plugins-base
    libdrm
    libva
    libvpx
    mesa
    systemd_lib
    wayland
    xorg.libX11
    xorg.libXrandr
    xorg.libXrender
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-fatal-warnings"
    "--disable-extra-checks"
    "--disable-debug"
    "--enable-encoders"
    (enFlag "drm" (libdrm != null) null)
    (enFlag "x11" (xorg.libX11 != null) null)
    (enFlag "glx" (xorg.libX11 != null && mesa != null) null)
    (enFlag "wayland" (wayland != null) null)
    (enFlag "egl" (wayland != null && mesa != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${gst-plugins-bad}/include/gstreamer-1.0"
    # FIXME: Gstreamer installs gstglconfig.h in the wrong location
    "-I${gst-plugins-bad}/lib/gstreamer-1.0/include"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  meta = with stdenv.lib; {
    description = "GStreamer VA-API hardware accelerated video processing";
    homepage = https://github.com/01org/gstreamer-vaapi;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
