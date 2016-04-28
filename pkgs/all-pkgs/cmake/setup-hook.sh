addCMakeParams() {
    addToSearchPath CMAKE_PREFIX_PATH $1
}

fixCmakeFiles() {
    # Replace occurences of /usr and /opt by /var/empty.
    echo "fixing cmake files..."
    find "$1" \( -type f -name "*.cmake" -o -name "*.cmake.in" -o -name CMakeLists.txt \) -print |
        while read fn; do
            sed -e 's^/usr\([ /]\|$\)^/var/empty\1^g' -e 's^/opt\([ /]\|$\)^/var/empty\1^g' < "$fn" > "$fn.tmp"
            mv "$fn.tmp" "$fn"
        done
}

cmakeConfigurePhase() {
    eval "$preConfigure"

    if [ -n "${fixCmake-true}" ]; then
        fixCmakeFiles .
    fi

    if [ -n "${createCmakeBuildDir-true}" ]; then
      cmakeDir="$(pwd)"
      mkdir -p $TMPDIR/build
      cd $TMPDIR/build
    fi

    if [ -z "$dontAddPrefix" ]; then
      cmakeFlagsArray+=("-DCMAKE_INSTALL_PREFIX=$prefix")
    fi

    # This installs shared libraries with a fully-specified install
    # name. By default, cmake installs shared libraries with just the
    # basename as the install name, which means that, on Darwin, they
    # can only be found by an executable at runtime if the shared
    # libraries are in a system path or in the same directory as the
    # executable. This flag makes the shared library accessible from its
    # nix/store directory.
    cmakeFlagsArray+=("-DCMAKE_INSTALL_NAME_DIR=$prefix/lib")

    # Avoid cmake resetting the rpath of binaries, on make install
    # And build always Release, to ensure optimisation flags
    cmakeFlagsArray+=(
      "-DCMAKE_BUILD_TYPE=Release"
      "-DCMAKE_SKIP_BUILD_RPATH=ON"
    )

    echo "cmake flags: $cmakeFlags ${cmakeFlagsArray[@]}"

    cmake ${cmakeDir:-.} $cmakeFlags "${cmakeFlagsArray[@]}"

    eval "$postConfigure"
}

if [ -n "${cmakeConfigure-true}" -a -z "$configurePhase" ]; then
    configurePhase=cmakeConfigurePhase
fi

envHooks+=(addCMakeParams)

makeCmakeFindLibs(){
  for flag in $NIX_CFLAGS_COMPILE $NIX_LDFLAGS; do
    case $flag in
      -I*)
        export CMAKE_INCLUDE_PATH="$CMAKE_INCLUDE_PATH${CMAKE_INCLUDE_PATH:+:}${flag:2}"
        ;;
      -L*)
        export CMAKE_LIBRARY_PATH="$CMAKE_LIBRARY_PATH${CMAKE_LIBRARY_PATH:+:}${flag:2}"
        ;;
    esac
  done
}

# not using setupHook, because it could be a setupHook adding additional
# include flags to NIX_CFLAGS_COMPILE
postHooks+=(makeCmakeFindLibs)
