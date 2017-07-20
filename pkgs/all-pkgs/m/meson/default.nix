{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.41.2";
in
buildPythonPackage {
  name = "meson-${version}";

  src = fetchPyPi {
    package = "meson";
    inherit version;
    sha256 = "ad1707717987fe8b7b65392b8327580105fcbdd5f2032bf3b7232b647284c95c";
  };

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}