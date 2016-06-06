{ stdenv, fetchurl, openssl, libogg, opus }:

stdenv.mkDerivation rec {
  name = "opusfile-0.7";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/opus/${name}.tar.gz";
    sha256 = "00f3wwjv3hxwg05g22s6mkkxikz80ljsn70g39cmi43jph9ysawy";
  };

  buildInputs = [ openssl libogg opus ];

  meta = {
    description = "High-level API for decoding and seeking in .opus files";
    homepage = http://www.opus-codec.org/;
    license = stdenv.lib.licenses.bsd3;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ fuuzetsu ];
  };
}
