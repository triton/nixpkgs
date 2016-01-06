{ stdenv, fetchurl, pkgconfig, zlib, expat, openssl, libidn, libpaper, dbus, libjpeg
, freetype, fontconfig, libpng, lcms2, jbig2dec
, x11Support ? false, xlibsWrapper ? null
, cupsSupport ? false, cups ? null
}:

assert x11Support -> xlibsWrapper != null;
assert cupsSupport -> cups != null;
let
  version = "9.18";
  sha256 = "18ad90za28dxybajqwf3y3dld87cgkx1ljllmcnc7ysspfxzbnl3";

  fonts = stdenv.mkDerivation {
    name = "ghostscript-fonts";

    srcs = [
      (fetchurl {
        url = "mirror://sourceforge/gs-fonts/ghostscript-fonts-std-8.11.tar.gz";
        sha256 = "00f4l10xd826kak51wsmaz69szzm2wp8a41jasr4jblz25bg7dhf";
      })
      (fetchurl {
        url = "mirror://gnu/ghostscript/gnu-gs-fonts-other-6.0.tar.gz";
        sha256 = "1cxaah3r52qq152bbkiyj2f7dx1rf38vsihlhjmrvzlr8v6cqil1";
      })
      # ... add other fonts here
    ];

    installPhase = ''
      mkdir "$out"
      mv -v * "$out/"
    '';
  };

in
stdenv.mkDerivation rec {
  name = "ghostscript-${version}";

  src = fetchurl {
    url = "http://downloads.ghostscript.com/public/${name}.tar.bz2";
    inherit sha256;
  };

  outputs = [ "out" "doc" ];

  enableParallelBuilding = true;

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libidn libpaper dbus freetype fontconfig libjpeg zlib libpng lcms2 jbig2dec ]
    ++ stdenv.lib.optional x11Support xlibsWrapper
    ++ stdenv.lib.optional cupsSupport cups
    ;

  NIX_ZLIB_INCLUDE = "${zlib}/include";

  patches = [
    ./fix-system-zlib.patch
    ./fix-ijs-device.patch
    ./add-gserrors.patch
    ./urw-font-files.patch
  ];

  makeFlags = [ "cups_serverroot=$(out)" "cups_serverbin=$(out)/lib/cups" ];

  preConfigure = ''
    rm -r freetype jbig2dec jpeg lcms2 libpng tiff zlib ijs

    sed "s@if ( test -f \$(INCLUDE)[^ ]* )@if ( true )@; s@INCLUDE=/usr/include@INCLUDE=/no-such-path@" -i base/unix-aux.mak
  '';

  configureFlags =
    [ "--with-system-libtiff"
      "--enable-fontconfig"
      "--enable-freetype"
      "--enable-dynamic"
      (if x11Support then "--with-x" else "--without-x")
      (if cupsSupport then "--enable-cups" else "--disable-cups")
    ];

  doCheck = true;

  # don't build/install statically linked bin/gs
  installTargets="install-so";

  postInstall = ''
    ln -s gsc "$out"/bin/gs
    mkdir -p "$doc/share/ghostscript"
    mv "$out/share/ghostscript/${version}" "$doc/share/ghostscript/${version}"
    ln -s "${fonts}" "$out/share/ghostscript/fonts"
  '';

  preFixup = stdenv.lib.strings.optionalString stdenv.isDarwin ''
    install_name_tool -change libgs.dylib.${version} $out/lib/libgs.dylib.${version} $out/bin/gs
  '';

  meta = {
    homepage = "http://www.ghostscript.com/";
    description = "PostScript interpreter (mainline version)";

    longDescription = ''
      Ghostscript is the name of a set of tools that provides (i) an
      interpreter for the PostScript language and the PDF file format,
      (ii) a set of C procedures (the Ghostscript library) that
      implement the graphics capabilities that appear as primitive
      operations in the PostScript language, and (iii) a wide variety
      of output drivers for various file formats and printers.
    '';

    license = stdenv.lib.licenses.gpl3Plus;

    platforms = stdenv.lib.platforms.all;
    maintainers = [ stdenv.lib.maintainers.viric ];
  };
}
