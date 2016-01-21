{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "log4cplus-1.2.0";

  src = fetchurl {
    url = "mirror://sourceforge/log4cplus/${name}.tar.bz2";
    sha256 = "1fb3g9l12sps3mv4xjiql2kcvj439mww3skz735y7113cnlcf338";
  };

  meta = {
    homepage = "http://log4cplus.sourceforge.net/";
    description = "a port the log4j library from Java to C++";
    license = stdenv.lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}
