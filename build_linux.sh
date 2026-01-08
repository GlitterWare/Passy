#! /bin/bash
cd "$(dirname "$0")"
set -euo pipefail

source .mpv.env

if [ ! -f "$MPV_LIB/libmpv.so" ]; then
  echo "Building hermetic MPV..."
  cmake -S "linux/mpv" -B "$MPV_BUILD" --log-level=ERROR
  cmake --build "$MPV_BUILD"
fi

echo "Building Passy with hermetic MPV..."
export PKG_CONFIG_PATH="$(echo /usr/lib/*-linux-gnu/pkgconfig):/usr/share/pkgconfig:$MPV_PKGCONFIG"
flutter build linux --no-version-check --suppress-analytics $@
PASSY_RELEASE="$(echo $(pwd)/build/linux/*/release)"
PATH="$PATH:$PASSY_RELEASE/prefix/bin"
PASSY_LIB="$PASSY_RELEASE/bundle/lib"

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
