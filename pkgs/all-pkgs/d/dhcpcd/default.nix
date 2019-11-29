{ stdenv
, fetchurl
, lib

, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "dhcpcd-8.1.2";

  src = fetchurl {
    url = "mirror://roy/dhcpcd/${name}.tar.xz";
    multihash = "QmdWcphXY2mxSwda5C1h3Q4tC58HKEWZHatjcJrs77YY6C";
    hashOutput = false;
    sha256 = "cbd3e7ab1584a5a3a49d863376fa138e5fa388397a3e27d2b35bb81a2e8c35ad";
  };

  buildInputs = [
    systemd_lib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=(
      "DBDIR=$TMPDIR/db"
      "SYSCONFDIR=$out/etc"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls = map (n: "${n}.distinfo.asc") src.urls;
        pgpKeyFingerprint = "A785 ED27 5595 5D9E 93EA 59F6 597F 97EA 9AD4 5549";
      };
    };
  };

  meta = with lib; {
    description = "A client for the Dynamic Host Configuration Protocol (DHCP)";
    homepage = http://roy.marples.name/projects/dhcpcd;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
