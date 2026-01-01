#! /bin/bash
set -euo pipefail

PASSY_LIB=$1

LIBS=(
  "libayatana-appindicator3.so"
  "libayatana-indicator3.so"
  "libayatana-ido3"
  "libdbusmenu-gtk3.so"
  "libdbusmenu-glib.so"
)

echo "Installing AppIndicator libraries into: $PASSY_LIB"
mkdir -p "$PASSY_LIB"

copy_lib() {
  local lib="$1"

  # Locate the library using ldconfig
  local path
  path=$(ldconfig -p | grep "$lib" | head -n1 | awk '{print $4}')

  if [[ -z "$path" ]]; then
    echo "ERROR: Could not find $lib on this system."
    exit 1
  fi

  echo "Found $lib at $path"

  dir=$(dirname "$path")
  base=$(basename "$path" | sed 's/\.so.*/.so/')

  cp -av "$dir/$base"* "$PASSY_LIB" || true
  patchelf --set-rpath '$ORIGIN' "$PASSY_LIB/$base"*
}

for lib in "${LIBS[@]}"; do
  copy_lib "$lib"
done

patchelf --set-rpath '$ORIGIN' "$PASSY_LIB/libsystem_tray_plugin.so"

echo "AppIndicator libraries installed."
