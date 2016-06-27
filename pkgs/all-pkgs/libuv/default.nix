{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool
}:

stdenv.mkDerivation rec {
  name = "libuv-${version}";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "libuv";
    repo = "libuv";
    rev = "v${version}";
    sha256 = "fcf5c65f24feb6cdb19f0c76462d929552d91d097c5c70672d96714192709943";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
