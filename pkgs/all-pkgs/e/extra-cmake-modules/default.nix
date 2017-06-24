{ stdenv
, cmake
, fetchurl
, ninja
}:

let
  majorVersion = "5.35";
  patchVersion = "0";
  version = "${majorVersion}.${patchVersion}";
in
stdenv.mkDerivation rec {
  name = "extra-cmake-modules-${version}";

  src = fetchurl {
    url = "mirror://kde/stable/frameworks/${majorVersion}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "b020fd5451f4aae9702b575dda07a125b5c1fcfb04e4c840f76063989e80ec30";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "53E6 B47B 45CE A3E0 D5B7  4577 58D0 EE64 8A48 B3BB";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
