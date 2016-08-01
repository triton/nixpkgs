{ stdenv
, docbook-xsl
, fetchurl
, intltool
, itstool
, libxslt
, makeWrapper

, adwaita-icon-theme
, atk
, clutter
, clutter-gtk
, dconf
, desktop_file_utils
, evince
, gdk-pixbuf
, gjs
, glib
, gmp
, gnome-desktop
, gnome-online-accounts
, gnome-online-miners
, gobject-introspection
, gsettings-desktop-schemas
, gtk3
, inkscape
, json-glib
, libgdata
, libsoup
, libxml2
, libzapojit
, pango
, poppler_utils
, rest
, tracker
, webkitgtk
}:

stdenv.mkDerivation rec {
  name = "gnome-documents-${version}";
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-documents/${versionMajor}/"
        + "${name}.tar.xz";
    sha256 = "a5fa496c5e80eccb8d2e5bba7f4d7dc4cc6c9f53d5bc028402428771be1237d2";
  };

  nativeBuildInputs = [
    docbook-xsl
    intltool
    itstool
    libxslt
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    clutter
    clutter-gtk
    dconf
    desktop_file_utils
    evince
    gdk-pixbuf
    gjs
    glib
    gmp
    gnome-desktop
    gnome-online-accounts
    gnome-online-miners
    gobject-introspection
    gsettings-desktop-schemas
    gtk3
    inkscape
    json-glib
    libgdata
    libsoup
    libxml2
    libzapojit
    pango
    poppler_utils
    rest
    tracker
    webkitgtk
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-schemas-compile"
    "--enable-getting-started"
    "--disable-documentation"
  ];

  preFixup = ''
    wrapProgram $out/bin/gnome-documents \
      --run 'if [ -z "$XDG_CACHE_DIR" ] ; then XDG_CACHE_DIR=$HOME/.cache ; fi' \
      --run 'if [ -d "$XDG_CACHE_DIR/gnome-documents" ] ; then mkdir -p "$XDG_CACHE_DIR/gnome-documents" ; fi' \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --set 'LD_PRELOAD' "${gnome-online-accounts}/lib/libgoa-1.0.so" \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A document manager application for GNOME";
    homepage = https://wiki.gnome.org/Apps/Documents;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
