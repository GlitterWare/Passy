#! /bin/bash
cd "$(dirname "$0")"
set -euo pipefail

PASSY_RELEASE="$(echo $(pwd)/build/linux/*/release)"
PATH="$PATH:$PASSY_RELEASE/prefix/bin"
PASSY_LIB="$PASSY_RELEASE/bundle/lib"
MPV_BUILD="$(pwd)/build/mpv"
MPV_PREFIX="$MPV_BUILD/prefix"
MPV_LIB="$MPV_PREFIX/lib"
MPV_INCLUDE="$MPV_PREFIX/include"
MPV_PKGCONFIG="$MPV_LIB/pkgconfig"

export PKG_CONFIG_PATH="$MPV_PKGCONFIG"
export LD_LIBRARY_PATH="$MPV_LIB"
export LIBRARY_PATH="$MPV_LIB"
export C_INCLUDE_PATH="$MPV_INCLUDE"
export CPLUS_INCLUDE_PATH="$MPV_INCLUDE"
export CFLAGS="-I$MPV_INCLUDE"
export CXXFLAGS="-I$MPV_INCLUDE"
export LDFLAGS="-L$MPV_LIB"

echo "Building hermetic MPV..."
cmake -S "linux/mpv" -B "$MPV_BUILD" --log-level=ERROR
cmake --build "$MPV_BUILD"

echo "Building Passy with hermetic MPV..."
export PKG_CONFIG_PATH="$(echo /usr/lib/*-linux-gnu/pkgconfig):/usr/share/pkgconfig:$MPV_PKGCONFIG"
flutter build linux --no-version-check --suppress-analytics -v $@

MPV_TEMP="$(mktemp -d)"
cp -r -P "$MPV_LIB"/pulseaudio/*.so* "$MPV_TEMP"
cp -r -P "$MPV_LIB"/*.so* "$MPV_TEMP"

echo "Patching MPV rpath..."
patchelf --set-rpath '$ORIGIN' "$MPV_TEMP"/*.so*

echo "Installing MPV libraries into Passy bundle..."
cp -r -P "$MPV_TEMP"/*.so* "$PASSY_LIB"
rm -rf "$MPV_TEMP"

echo "Patching media_kit rpath..."
patchelf --set-rpath '$ORIGIN' "$PASSY_LIB"/libmedia_kit*.so

echo "Build complete."
