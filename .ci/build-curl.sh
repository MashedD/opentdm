#!/bin/sh
# Build a small static libcurl for a MinGW-w64 target, using Schannel (the
# TLS stack built into Windows), so the game DLL needs no OpenSSL or other
# DLLs next to it.
#
# Usage: .ci/build-curl.sh HOST PREFIX
#   HOST    i686-w64-mingw32 or x86_64-w64-mingw32
#   PREFIX  install directory; libcurl.pc ends up in PREFIX/lib/pkgconfig
#
# Building again with the same PREFIX does nothing once the install exists.

set -eu

CURL_VERSION=8.23.0
CURL_SHA256=e3de77cfa6367083c776a26647fc9f633b538c06c3baa73d931a252ac8f72b49

[ $# -eq 2 ] || { echo "usage: $0 HOST PREFIX" >&2; exit 2; }
host=$1
mkdir -p "$2"
prefix=$(cd "$2" && pwd)

if [ -f "$prefix/lib/libcurl.a" ] && [ -f "$prefix/.curl-$CURL_VERSION" ]; then
    echo "libcurl $CURL_VERSION for $host already built in $prefix"
    exit 0
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

tarball=curl-$CURL_VERSION.tar.gz
echo "Downloading $tarball"
curl -fsSL --retry 3 -o "$work/$tarball" "https://curl.se/download/$tarball"
echo "$CURL_SHA256  $work/$tarball" | sha256sum -c -
tar -xzf "$work/$tarball" -C "$work"

cd "$work/curl-$CURL_VERSION"
./configure --host="$host" --prefix="$prefix" \
    --disable-shared --enable-static \
    --with-schannel --enable-ipv6 \
    --disable-dict --disable-file --disable-ftp --disable-gopher \
    --disable-imap --disable-ldap --disable-ldaps --disable-mqtt \
    --disable-pop3 --disable-rtsp --disable-smb --disable-smtp \
    --disable-telnet --disable-tftp --disable-websockets \
    --disable-docs --disable-manual --disable-curldebug \
    --without-brotli --without-zstd --without-zlib --without-libpsl \
    --without-libidn2 --without-nghttp2 --without-ngtcp2 --without-nghttp3 \
    --without-libssh2 --without-librtmp \
    CFLAGS="-O2"
make -j"$(nproc)" -C lib
make -C lib install
make -C include install
install -d "$prefix/lib/pkgconfig"
install -m 644 libcurl.pc "$prefix/lib/pkgconfig/"
touch "$prefix/.curl-$CURL_VERSION"
echo "libcurl $CURL_VERSION for $host installed in $prefix"
