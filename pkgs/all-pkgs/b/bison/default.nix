{ stdenv
, fetchurl
, lib
, gnum4

, type ? "full"
}:

let
  inherit (lib)
    boolEn
    optionalAttrs
    optionalString;

  tarballUrls = version: [
    "mirror://gnu/bison/bison-${version}.tar.xz"
  ];

  version = "3.4.1";
in
stdenv.mkDerivation (rec {
  name = "bison-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "27159ac5ebf736dffd5636fd2cd625767c9e437de65baa63cb0de83570bd820d";
  };

  nativeBuildInputs = [
    gnum4
  ];

  # We need this for bison to work correctly when being
  # used during the build process
  propagatedBuildInputs = [
    gnum4
  ];

  configureFlags = [
    "--${boolEn (type != "bootstrap")}-threads"
    "--${boolEn (type != "bootstrap")}-assert"
    "--${boolEn (type != "bootstrap")}-nls"
    # We don't actually need perl for building bison
    "ac_cv_path_PERL=perl"
  ];

  postInstall = optionalString (type != "full") ''
    rm -r "$out"/share/{doc,man,info}
  '';

  dontPatchShebangs = true;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.4.1";
      inherit (src) outputHashAlgo;
      outputHash = "27159ac5ebf736dffd5636fd2cd625767c9e437de65baa63cb0de83570bd820d";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "7DF8 4374 B1EE 1F97 64BB  E25D 0DDC AA32 78D5 264E";
      };
    };
  };

  meta = with lib; {
    description = "Yacc-compatible parser generator";
    homepage = "http://www.gnu.org/software/bison/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
} // optionalAttrs (type != "bootstrap") {
  allowedReferences = [
    "out"
    gnum4
  ] ++ stdenv.cc.runtimeLibcLibs;
})
