{ stdenv
, fetchPyPi
, lib
, python
, setuptools
, unzip
}:

let
  inherit (lib)
    optionals;

  version = "0.30.0";
in
stdenv.mkDerivation rec {
  name = "wheel-${version}";

  src = fetchPyPi {
    package = "wheel";
    inherit version;
    sha256 = "9515fe0a94e823fd90b08d22de45d7bde57c90edce705b22f5e1ecf7e1b653c8";
  };

  nativeBuildInputs = [
    python
    setuptools
    unzip
  ];

  buildPhase = ''
    ${python.interpreter} setup.py bdist_wheel
  '';

  installPhase = ''
    pushd dist/
      mkdir -pv $out/${python.sitePackages}
      unzip -d $out/${python.sitePackages} wheel-*.whl
    popd
  '';

  meta = with lib; {
    description = "A built-package format for Python";
    homepage = https://bitbucket.org/pypa/wheel/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
