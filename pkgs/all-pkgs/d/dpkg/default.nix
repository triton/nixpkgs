{ stdenv
, fetchurl
, makeWrapper
, perl

, bzip2
, libselinux
, ncurses
, xz
, zlib
}:

let
  version = "1.18.10";
in
stdenv.mkDerivation {
  name = "dpkg-${version}";

  src = fetchurl {
    url = "mirror://debian/pool/main/d/dpkg/dpkg_${version}.tar.xz";
    sha256 = "025524da41ba18b183ff11e388eb8686f7cc58ee835ed7d48bd159c46a8b6dc5";
  };

  nativeBuildInputs = [
    makeWrapper
    perl
  ];

  buildInputs = [
    bzip2
    libselinux
    ncurses
    xz
    zlib
  ];

  preConfigure = ''
    export PERL_LIBDIR=$out/${perl.libPrefix}
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "admindir=$TMPDIR/var"
    )
  '';

  preFixup = ''
    perlProgs=($(grep -r '#!${perl}' "$out/bin" | awk -F: '{print $1}' | sort | uniq))
    for perlProg in "''${perlProgs[@]}"; do
      wrapProgram $perlProg \
        --prefix PATH : "$out/bin" \
        --prefix PERL5LIB : "$out/${perl.libPrefix}"
    done
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
