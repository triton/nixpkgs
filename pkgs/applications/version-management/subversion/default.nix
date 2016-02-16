{ bdbSupport ? false # build support for Berkeley DB repositories
, httpServer ? false # build Apache DAV module
, httpSupport ? false # client must support http
, pythonBindings ? false
, perlBindings ? false
, javahlBindings ? false
, saslSupport ? false
, stdenv, fetchurl, apr, aprutil, zlib, sqlite
, apacheHttpd ? null, expat, swig ? null, jdk ? null, python ? null, perl ? null
, sasl ? null, serf ? null
}:

assert bdbSupport -> aprutil.bdbSupport;
assert httpServer -> apacheHttpd != null;
assert pythonBindings -> swig != null && python != null;
assert javahlBindings -> jdk != null && perl != null;

let
  common = { version, sha1 }: stdenv.mkDerivation rec {
    inherit version;
    name = "subversion-${version}";

    src = fetchurl {
      url = "mirror://apache/subversion/${name}.tar.bz2";
      inherit sha1;
    };

    buildInputs = [ zlib apr aprutil sqlite ]
      ++ stdenv.lib.optional httpSupport serf
      ++ stdenv.lib.optional pythonBindings python
      ++ stdenv.lib.optional perlBindings perl
      ++ stdenv.lib.optional saslSupport sasl;

    configureFlags = ''
      ${if bdbSupport then "--with-berkeley-db" else "--without-berkeley-db"}
      ${if httpServer then "--with-apxs=${apacheHttpd}/bin/apxs" else "--without-apxs"}
      ${if pythonBindings || perlBindings then "--with-swig=${swig}" else "--without-swig"}
      ${if javahlBindings then "--enable-javahl --with-jdk=${jdk}" else ""}
      --disable-keychain
      ${if saslSupport then "--with-sasl=${sasl}" else "--without-sasl"}
      ${if httpSupport then "--with-serf=${serf}" else "--without-serf"}
      --with-zlib=${zlib}
      --with-sqlite=${sqlite}
    '';

    preBuild = ''
      makeFlagsArray=(APACHE_LIBEXECDIR=$out/modules)
    '';

    postInstall = ''
      if test -n "$pythonBindings"; then
          make swig-py swig_pydir=$(toPythonPath $out)/libsvn swig_pydir_extra=$(toPythonPath $out)/svn
          make install-swig-py swig_pydir=$(toPythonPath $out)/libsvn swig_pydir_extra=$(toPythonPath $out)/svn
      fi

      if test -n "$perlBindings"; then
          make swig-pl-lib
          make install-swig-pl-lib
          cd subversion/bindings/swig/perl/native
          perl Makefile.PL PREFIX=$out
          make install
          cd -
      fi

      mkdir -p $out/share/bash-completion/completions
      cp tools/client-side/bash_completion $out/share/bash-completion/completions/subversion
    '';

    inherit perlBindings pythonBindings;

    # Parallel Building works fine but Parallel Install fails
    parallelInstall = false;

    meta = {
      description = "A version control system intended to be a compelling replacement for CVS in the open source community";
      homepage = http://subversion.apache.org/;
      maintainers = with stdenv.lib.maintainers; [ eelco lovek323 ];
      hydraPlatforms = stdenv.lib.platforms.linux;
    };

  };

in {

  subversion18 = common {
    version = "1.8.15";
    sha1 = "680acf88f0db978fbbeac89ed63776d805b918ef";
  };

  subversion19 = common {
    version = "1.9.3";
    sha1 = "27e8df191c92095f48314a415194ec37c682cbcf";
  };

}
