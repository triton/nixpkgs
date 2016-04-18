{ stdenv
, fetchurl

, bzip2
, gst-plugins-base_0
, gstreamer_0
, orc
, zlib
}:

stdenv.mkDerivation rec {
  name = "gst-ffmpeg-0.10.13";

  src = fetchurl {
    url = "https://gstreamer.freedesktop.org/src/gst-ffmpeg/${name}.tar.bz2";
    sha256 = "0qmvgwcfybci78sd73mhvm4bsb7l0xsk9yljrgik80g011ds1z3n";
  };

  buildInputs = [
    bzip2
    gst-plugins-base_0
    gstreamer_0
    orc
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-valgrind"
    "--disable-docbook"
    "--disable-gtk-doc"
    "--enable-orc"
    "--enable-lgpl"
    "--without-system-ffmpeg"
  ];

  meta = with stdenv.lib; {
    description = "FFmpeg based gstreamer plugin";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
