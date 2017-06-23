{ stdenv
, buildPythonPackage
, fetchurl
, lib

, fasteners
, librsync
, lockfile
}:

let
  versionMajor = "0.7";
  version = "${versionMajor}.13.1";
in
buildPythonPackage rec {
  name = "duplicity-${version}";

  src = fetchurl {
    url = "https://code.launchpad.net/duplicity/${versionMajor}-series/"
      "${version}/+download/${name}.tar.gz";
    multihash = "QmPAzT2Z9NoBDjaErbey5Es6S8bd86TkS6MpgdhncWUTzs";
    sha256 = "adb8668fb10e0b0f91cb77f758d02c02bf5c02e6c4835904a82cbdab6db4bef2";
  };

  buildInputs = [
    librsync
  ];

  propagatedBuildInputs = [
    fasteners
    lockfile
  ];

  meta = with lib; {
    description = "Encrypted bandwidth-efficient backup using the rsync algorithm";
    homepage = "http://www.nongnu.org/duplicity";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
