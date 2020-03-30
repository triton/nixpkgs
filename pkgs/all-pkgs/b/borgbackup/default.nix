{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, pythonOlder
, setuptools-scm

, acl
, libb2
, llfuse
, lz4
, msgpack-python
, openssl
, zstd
}:

let
  version = "1.1.11";
in
buildPythonPackage rec {
  name = "borgbackup-${version}";

  src = fetchPyPi {
    package = "borgbackup";
    inherit version;
    sha256 = "36090992ba795a5a5091fcd407b67be9bf26d0e88020892d31d7ac81fa970fa4";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  buildInputs = [
    acl
    libb2
    lz4
    openssl
    zstd
  ];

  propagatedBuildInputs = [
    msgpack-python
    llfuse
  ];

  BORG_LIBB2_PREFIX = libb2;
  BORG_LIBLZ4_PREFIX = lz4;
  BORG_LIBZSTD_PREFIX = zstd;
  BORG_OPENSSL_PREFIX = openssl;

  postPatch = ''
    # Remove bundling
    rm -r src/borg/algorithms/{blake2,lz4,zstd}

    # Fix searching in /usr or /opt
    sed -i setup.py \
      -e 's,/usr,/non-existant-path,g' \
      -e 's,/opt,/non-existant-path,g'
  '';

  disabled = pythonOlder "3.5";

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
