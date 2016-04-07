{ stdenv
, bison
, fetchurl
, flex
, gettext
, perl
, python

, glib
, gobject-introspection
, libcap
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "gstreamer-1.8.0";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/gstreamer/${name}.tar.xz";
    sha256Url = "${url}.sha256sum";
    sha256 = "947a314a212b5d94985d89b43440dbe66b696e12bbdf9a2f78967b98d74abedc";
  };

  nativeBuildInputs = [
    bison
    flex
    gettext
    perl
    python
  ];

  buildInputs = [
    glib
    gobject-introspection
    libcap
  ];

  setupHook = ./setup-hook-1.0.sh;

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-fatal-warnings"
    "--disable-extra-checks"
    "--enable-gst-debug"
    "--disable-gst-tracer-hooks"
    "--enable-parse"
    "--enable-option-parsing"
    "--disable-trace"
    "--disable-alloc-trace"
    "--enable-registry"
    "--enable-plugin"
    "--disable-debug"
    "--disable-profiling"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-examples"
    "--disable-static-plugins"
    "--disable-tests"
    "--disable-failing-tests"
    "--disable-benchmarks"
    "--enable-tools"
    "--disable-poisoning"
    "--enable-largefile"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-docbook"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
    "--disable-check"
    "--enable-Bsymbolic"
  ];

  preFixup =
    /* Needed for orc-using gst plugins on hardened/PaX systems */ ''
      paxmark m \
        $out/bin/gst-launch* \
        $out/libexec/gstreamer-0.10/gst-plugin-scanner
    '';

  meta = with stdenv.lib; {
    description = "Multimedia framework";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
