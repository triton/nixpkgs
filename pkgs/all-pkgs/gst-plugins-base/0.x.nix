{ stdenv
, fetchurl

, alsaLib
, cdparanoia
, freetype
, glib
, gnome
, gobject-introspection
, gstreamer_0
, isocodes
, libgudev
, libogg
, libtheora
, libv4l
, libvisual
, libvorbis
, libxml2
, orc
, pango
#, tremor
, xorg
, zlib
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "gst-plugins-base-0.10.36";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gst-plugins-base/${name}.tar.xz";
    sha256 = "0jp6hjlra98cnkal4n6bdmr577q8mcyp3c08s3a02c4hjhw5rr0z";
  };

  patches = [
    ./gst-plugins-base-0.10-gcc-4.9.patch
    ./gst-plugins-base-0.10-resync-ringbuffer.patch
  ];

  postPatch = ''
    # Fix hardcoded path
    sed -i configure \
      -e 's@/bin/echo@echo@g'

    # The AC_PATH_XTRA macro unnecessarily pulls in libSM and libICE even
    # though they are not actually used. This needs to be fixed upstream by
    # replacing AC_PATH_XTRA with PKG_CONFIG calls.
    sed -i configure \
      -e 's:X_PRE_LIBS -lSM -lICE:X_PRE_LIBS:'
  '';

  configureFlags = [
    "--enable-option-checking"
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-debug"
    "--disable-profiling"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-examples"
    "--enable-external"
    "--enable-experimental"
    "--enable-largefile"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
    (enFlag "orc" (orc != null) null)
    "--enable-Bsymbolic"
    "--enable-adder"
    "--enable-app"
    "--enable-audioconvert"
    "--enable-audiorate"
    "--enable-audiotestsrc"
    "--enable-encoding"
    "--enable-ffmpegcolorspace"
    "--enable-gdp"
    "--enable-playback"
    # Speex ????
    "--enable-audioresample"
    (enFlag "subparse" (libxml2 != null) null)
    "--enable-tcp"
    "--enable-typefind"
    "--enable-videotestsrc"
    "--enable-videorate"
    "--enable-videoscale"
    "--enable-volume"
    (enFlag "iso-codes" (isocodes != null) null)
    (enFlag "zlib" (zlib != null) null)
    (enFlag "x" (xorg.libX11 != null) null)
    (enFlag "xvideo" (xorg.libXv != null) null)
    (enFlag "xshm" (xorg.libXext != null) null)
    (enFlag "gst_v4l" (libv4l != null) null)
    (enFlag "alsa" (alsaLib != null) null)
    (enFlag "cdparanoia" (cdparanoia != null) null)
    (enFlag "gnome_vfs" (gnome.gnome_vfs != null) null)
    # FIXME: compilation fails with ivorbis(tremor)
    "--disable-ivorbis"
    "--enable-gio"
    (enFlag "libvisual" (libvisual != null) null)
    (enFlag "ogg" (libogg != null) null)
    "--disable-oggtest"
    (enFlag "pango" (pango != null) null)
    (enFlag "theora" (libtheora != null) null)
    (enFlag "vorbis" (libvorbis != null) null)
    "--disable-vorbistest"
    "--disable-freetypetest"
    "--with-audioresample-format=float"
    "--with-x"
    (wtFlag "gudev" (libgudev != null) null)
  ];

  buildInputs = [
    alsaLib
    cdparanoia
    freetype
    glib
    gnome.gnome_vfs
    gobject-introspection
    gstreamer_0
    isocodes
    libgudev
    libogg
    libtheora
    libv4l
    libvisual
    libvorbis
    libxml2
    orc
    pango
    #tremor
    xorg.libX11
    xorg.libXext
    xorg.libXv
    zlib
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Basepack of plugins for gstreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
