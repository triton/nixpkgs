{ stdenv
, fetchurl

, iproute
, lzo
, openssl_1-0-2
, pam
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "openvpn-2.4.2";

  src = fetchurl {
    url = "https://swupdate.openvpn.net/community/releases/${name}.tar.gz";
    hashOutput = false;
    sha256 = "b24740c9d44a81eaf2befc4846d51445a520104321e32aaf0c135ed2e098a624";
  };

  buildInputs = [
    iproute
    lzo
    openssl_1-0-2
    pam
    systemd_lib
  ];

  # This fix should be removed in 2.3.13+
  postPatch = ''
    sed -i 's,systemd-daemon,systemd,g' configure
  '';

  configureFlags = [
    "--enable-x509-alt-username"
    "--enable-iproute2"
    "--enable-systemd"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        "0330 0E11 FED1 6F59 715F  9996 C29D 97ED 198D 22A3"
        "6D04 F8F1 B017 3111 F499  795E 2958 4D9F 4086 4578"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A robust and highly flexible tunneling application";
    homepage = http://openvpn.net/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
