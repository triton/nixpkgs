{ stdenv
, fetchurl
, fetchpatch
, substituteAll

, xorg
, freetype
, fontconfig
, zlib
, libjpeg
, libpng
, libmng
, which
, mesaSupported ? true
, mesa_noglu
, mesa_glu
, openssl
, dbus
, cups
, pulseaudio_lib
, libtiff
, glib
, icu
, mysql_lib
, postgresql
, sqlite
, perl
, coreutils
, buildMultimedia ? true
  , alsa-lib
, gstreamer_0
, gst-plugins-base_0
, buildWebkit ? false # TODO: Maybe fix
, flashplayerFix ? false
  , gdk-pixbuf
, gtkStyle ? false
  , libgnomeui
  , gtk2
  , GConf
  , gnome_vfs
, developerBuild ? false
, docs ? false
, examples ? false
, demos ? false
}:

with {
  inherit (stdenv.lib)
    optional
    optionals
    optionalString
    qtFlag;
};

let
  qtFlag =
    flag:
    condition:
    value:

    if condition == null then
      null
    else
      "-${
        if condition == true then
          ""
        else
          "no-"
      }${flag}${
        if value != null && condition == true then
          " ${value}"
        else
          ""
      }";
in

# TODO:
#  * move some plugins (e.g., SQL plugins) to dedicated derivations to avoid
#    false build-time dependencies

stdenv.mkDerivation rec {
  name = "qt-${version}";
  versionMajor = "4.8";
  versionMinor = "7";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "http://download.qt-project.org/official_releases/qt/${versionMajor}"
        + "/${version}/qt-everywhere-opensource-src-${version}.tar.gz";
    sha256 = "183fca7n7439nlhxyg1z7aky0izgbyll3iwakw4gwivy16aj5272";
  };

  patches = [
    ./glib-2.32.patch
    ./libressl.patch
    (substituteAll {
      src = ./dlopen-absolute-paths.diff;
      inherit cups icu;
      inherit (xorg) libXfixes;
      glibc = stdenv.cc.libc;
      openglDriver =
        if mesaSupported then
          mesa_noglu.driverSearchPath
        else
          "/no-such-path";
    })
  ] ++ optional gtkStyle (substituteAll {
    src = ./dlopen-gtkstyle.diff;
    # substituteAll ignores env vars starting with capital letter
    gconf = GConf;
    inherit gnome_vfs libgnomeui gtk;
  }) ++ optional flashplayerFix (substituteAll {
    src = ./dlopen-webkit-nsplugin.diff;
    inherit gtk gdk_pixbuf;
  }) ++ [
    (fetchpatch {
      name = "fix-medium-font.patch";
      url = "http://anonscm.debian.org/cgit/pkg-kde/qt/qt4-x11.git/plain/debian/patches/"
          + "kubuntu_39_fix_medium_font.diff?id=21b342d71c19e6d68b649947f913410fe6129ea4";
      sha256 = "0bli44chn03c2y70w1n8l7ss4ya0b40jqqav8yxrykayi01yf95j";
    })
  ];

  prePatch = ''
    substituteInPlace configure \
      --replace /bin/pwd pwd
    substituteInPlace src/corelib/global/global.pri \
      --replace /bin/ls ${coreutils}/bin/ls
    sed -e 's@/\(usr\|opt\)/@/var/empty/@g' \
      -i config.tests/*/*.test \
      -i mkspecs/*/*.conf
  '';

  prefixKey = "-prefix ";
  configureFlags = [
    "-v"
    "-release"
    "-no-debug"
    #"-no-debug-release"
    (qtFlag "developer-build" developerBuild null)
    "-opensource"
    "-no-commercial"
    "-shared"
    "-no-static"
    "-no-fast"
    "-largefile"
    #"-system-proxies"
    "-exceptions"
    #"-accessability"
    #"-stl"
    #"-sql"
    #"-qt-sql-<driver>"
    #"-plugin-sql-<driver>"
    (qtFlag "sql-mysql" (mysql_lib != null) null)
    "-system-sqlite"
    #"-qt3Support"
    #"-xmlpatterns"
    (qtFlag "multimedia" buildMultimedia null)
    #"-no-phonon"
    #"-phonon-backend"
    "-svg"
    (qtFlag "webkit" buildWebkit null)
    #"-no-webkit-debug"
    "-javascript-jit"
    "-script"
    "-scripttools"
    #"-declaritive"
    #"-no-declaritive-debug"
    #"-platfrom <target>"
    #"-graphicssystem <sys>" raster opengl openvg
    # CPU features
    #"-mmx"
    #"-no-3dnow"
    "-sse"
    #"-sse2"
    #"-sse3"
    #"-ssse3"
    #"-sse4.1"
    #"-sse4.2"
    #"-no-avx"
    #"-neon"

    #"-qtnamespace"
    #"-qtlibinfix"

    "-system-zlib"
    #"-gif"
    "-system-libtiff"
    "-system-libpng"
    "-system-libmng"
    "-system-libjpeg"
    "-openssl-linked"
    #"-ptmalloc""

    "-make libs"
    "-make tools"
    "-make translations"
    (qtFlag "make" demos "demos")
    (qtFlag "make" examples "examples")
    (qtFlag "make" docs "docs")

    "-optimized-qmake"
    #"-gui"
    #"-nis"
    (qtFlag "cups" (cups != null) null)
    "-iconv"
    #"-pch"
    "-dbus-linked"
    #"-reduc-relocations"

    #"-gtkstyle"
    #"-system-nas-sound"
    #"-egl" # replace glx
    (qtFlag "opengl" true null)
    #"-openvg"
    "-sm"
    "-xshape"
    #"-xvideo"
    "-xsync"
    "-xinerama"
    "-xcursor"
    "-xfixes"
    "-xrandr"
    "-xrender"
    #"mitshm"
    "-fontconfig"
    "-xinput"
    "-xkb"
    "-glib"




    "-no-separate-debug-info"
    "-confirm-license"
    "-qdbus"
    "-xmlpatterns"
    "-audio-backend"
  ];

  preConfigure = ''
    export LD_LIBRARY_PATH="`pwd`/lib:$LD_LIBRARY_PATH"
    configureFlags+=(
      "-docdir $out/share/doc/${name}"
      "-plugindir $out/lib/qt4/plugins"
      "-importdir $out/lib/qt4/imports"
      "-examplesdir $out/share/doc/${name}/examples"
      "-demosdir $out/share/doc/${name}/demos"
      "-datadir $out/share/${name}"
      "-translationdir $out/share/${name}/translations"
    )
  '' + optionalString stdenv.cc.isClang ''
    sed -e 's/QMAKE_CC = gcc/QMAKE_CC = clang/' \
      -i mkspecs/common/g++-base.conf
    sed -e 's/QMAKE_CXX = g++/QMAKE_CXX = clang++/' \
      -i mkspecs/common/g++-base.conf
  '';

  nativeBuildInputs = [
    perl
    which
  ];

  buildInputs = [
    cups # Qt dlopen's libcups instead of linking to it
    dbus.libs
    fontconfig
    freetype
    glib
    icu
    libjpeg
    libmng
    mysql_lib
    libpng
    pulseaudio_lib
    libtiff
    openssl
    postgresql
    sqlite
    xorg.libSM
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.libXv
    zlib
  ] ++ optionals gtkStyle [ gtk2 gdk-pixbuf ]
    ++ optionals mesaSupported [ mesa_noglu mesa_glu ]
    ++ optional ((buildWebkit || buildMultimedia)) alsa-lib
    ++ optionals (buildWebkit || buildMultimedia) [ gstreamer_0 gst-plugins-base_0 ];

  postInstall = ''
    cp -v src/3rdparty/webkit/Source/JavaScriptCore/release/libjscore.a $out/lib
    cp -v src/3rdparty/webkit/Source/WebCore/release/libwebcore.a $out/lib
  '';

  crossAttrs = {
    # I've not tried any case other than i686-pc-mingw32.
    # -nomake tools:   it fails linking some asian language symbols
    # -no-svg: it fails to build on mingw64
    configureFlags = ''
      -static
      -release
      -confirm-license
      -opensource
      -no-opengl
      -no-phonon
      -no-svg
      -make qmake
      -make libs
      -nomake tools
      -nomake demos
      -nomake examples
      -nomake docs
    '';
    patches = [];
    preConfigure = ''
      sed -i mkspecs/win32-g++/qmake.conf \
        -e 's/ g++/ ${stdenv.cross.config}-g++/' \
        -e 's/ gcc/ ${stdenv.cross.config}-gcc/' \
        -e 's/ ar/ ${stdenv.cross.config}-ar/' \
        -e 's/ strip/ ${stdenv.cross.config}-strip/' \
        -e 's/ windres/ ${stdenv.cross.config}-windres/'
    '';

    # I don't know why it does not install qmake
    postInstall = ''
      cp bin/qmake* $out/bin
    '';
    dontSetConfigureCross = true;
    dontStrip = true;
  };

  meta = with stdenv.lib; {
    description = "A cross-platform application framework for C++";
    homepage = http://qt-project.org/;
    license = licenses.lgpl21Plus; # or gpl3
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
