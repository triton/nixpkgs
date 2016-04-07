{ stdenv, fetchFromGitHub, alsaLib, aubio, boost, cairomm, curl, doxygen, dbus, fftw
, fftwSinglePrec, flac, glibc, glibmm, graphviz, gtk2, gtkmm2, libjack2
, libgnomecanvas, libgnomecanvasmm, liblo, libmad, libogg, librdf
, librdf_raptor, librdf_rasqal, libsamplerate, libsigcxx, libsndfile
, libusb, libuuid, libxml2, libxslt, lilv-svn, lv2, makeWrapper, pango
, perl, pkgconfig, python, rubberband, serd, sord-svn, sratom, suil, taglib, vampSDK }:

let
  # Ardour git repo uses a mix of annotated and lightweight tags. Annotated
  # tags are used for MAJOR.MINOR versioning, and lightweight tags are used
  # in-between; MAJOR.MINOR.REV where REV is the number of commits since the
  # last annotated tag. A slightly different version string format is needed
  # for the 'revision' info that is built into the binary; it is the format of
  # "git describe" when _not_ on an annotated tag(!): MAJOR.MINOR-REV-HASH.

  # Version to build.
  tag = "4.4";
in

stdenv.mkDerivation rec {
  name = "ardour-${tag}";

  src = fetchFromGitHub {
    owner = "Ardour";
    repo = "ardour";
    rev = "b00d75adf63db155ef2873bd9d259dc8ca256be6";
    sha256 = "1gnrcnq2ksnh7fsa301v1c4p5dqrbqpjylf02rg3za3ab58wxi7l";
  };

  buildInputs =
    [ alsaLib aubio boost cairomm curl doxygen dbus fftw fftwSinglePrec flac glibc
      glibmm graphviz gtk2 gtkmm2 libjack2 libgnomecanvas libgnomecanvasmm liblo
      libmad libogg librdf librdf_raptor librdf_rasqal libsamplerate
      libsigcxx libsndfile libusb libuuid libxml2 libxslt lilv-svn lv2
      makeWrapper pango perl pkgconfig python rubberband serd sord-svn sratom suil taglib vampSDK
    ];

  # ardour's wscript has a "tarball" target but that required the git revision
  # be available. Since this is an unzipped tarball fetched from github we
  # have to do that ourself.
  patchPhase = ''
    printf '#include "libs/ardour/ardour/revision.h"\nnamespace ARDOUR { const char* revision = \"${tag}-${builtins.substring 0 8 src.rev}\"; }\n' > libs/ardour/revision.cc
    sed 's|/usr/include/libintl.h|${glibc}/include/libintl.h|' -i wscript
    patchShebangs ./tools/
  '';

  configurePhase = "python waf configure --optimize --docs --with-backends=jack,alsa --prefix=$out";

  buildPhase = "python waf";

  installPhase = ''
    python waf install

    # Install desktop file
    mkdir -p "$out/share/applications"
    cat > "$out/share/applications/ardour.desktop" << EOF
    [Desktop Entry]
    Name=Ardour 4
    GenericName=Digital Audio Workstation
    Comment=Multitrack harddisk recorder
    Exec=$out/bin/ardour4
    Icon=$out/share/ardour4/icons/ardour_icon_256px.png
    Terminal=false
    Type=Application
    X-MultipleArgs=false
    Categories=GTK;Audio;AudioVideoEditing;AudioVideo;Video;
    EOF
  '';

  meta = with stdenv.lib; {
    description = "Multi-track hard disk recording software";
    homepage = http://ardour.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
