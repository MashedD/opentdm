#!/bin/sh
# Build the OpenTDM game library.
#
# Usage: ./build.sh [TARGET...]
#   linux   gameARCH.so for this machine, linked against the system libcurl
#   win32   gamex86.dll, cross-compiled with MinGW-w64
#   win64   gamex86_64.dll, cross-compiled with MinGW-w64
#   all     linux, win32 and win64
#   clean   remove build output (the libcurl builds in .deps are kept)
#
# With no TARGET, builds linux. The Windows targets build a static libcurl
# into .deps/ the first time (see .ci/build-curl.sh). Extra make variables
# can be passed through the environment, e.g. MAKEFLAGS="V=1" ./build.sh.

set -eu
cd "$(dirname "$0")"

jobs=$(nproc 2>/dev/null || echo 2)

build_windows() {
    config=$1 host=$2
    deps=.deps/$host
    .ci/build-curl.sh "$host" "$deps"
    PKG_CONFIG_PATH='' PKG_CONFIG_LIBDIR=$PWD/$deps/lib/pkgconfig \
        make -j"$jobs" CONFIG_FILE="$config"
}

[ $# -gt 0 ] || set -- linux

for target in "$@"; do
    case $target in
    linux) make -j"$jobs" ;;
    win32) build_windows .config-win32 i686-w64-mingw32 ;;
    win64) build_windows .config-win64 x86_64-w64-mingw32 ;;
    all) "$0" linux win32 win64 ;;
    clean) rm -rf build game*.so game*.dll ;;
    *) echo "unknown target: $target (use linux, win32, win64, all or clean)" >&2; exit 2 ;;
    esac
done
