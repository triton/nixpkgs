{ stdenv
, fetchurl
, help2man
, lib

, libcddb
, ncurses
}:

let
  inherit (lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "libcdio-0.93";

  src = fetchurl {
    url = "mirror://gnu/libcdio/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "f8276629226c7e1e74209b66ca421d09d6aec87f72f60ae9b1d3debd0a13dda8";
  };

  nativeBuildInputs = [
    help2man
  ];

  buildInputs = [
    libcddb
    ncurses
  ];

  configureFlags = [
    "--enable-maintainer-mode"
    "--enable-cxx"
    "--enable-cpp-progs"
    "--disable-example-progs"
    "--enable-largefile"
    "--enable-joliet"
    "--enable-rpath"
    "--enable-rock"
    "--${boolEn (libcddb != null)}-cddb"
    "--enable-vcd-info"
    "--with-cd-drive"
    "--with-cd-info"
    "--with-cdda-player"
    "--with-cd-read"
    "--with-iso-info"
    "--with-iso-read"
    "--with-versioned-libs"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      # R. Bernstein
      pgpKeyFingerprint = "DAA6 3BC2 5820 34A0 2B92  3D52 1A8D E500 8275 EC21";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A library for OS-independent CD-ROM and CD image access";
    homepage = http://www.gnu.org/software/libcdio/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
