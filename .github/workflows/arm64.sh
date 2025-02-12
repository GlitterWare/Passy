#! /bin/bash
cd /Passy

echo "===================================================="
echo "Install dependencies"
echo "===================================================="

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev binutils coreutils desktop-file-utils fakeroot fuse libgdk-pixbuf2.0-dev patchelf python3-pip python3-setuptools squashfs-tools strace util-linux zsync git file unzip zip wget curl libc6
DEBIAN_FRONTEND=noninteractive apt-get -y install libayatana-appindicator3-dev libappindicator3-dev libmpv-dev mpv

echo "===================================================="
echo "Configure"
echo "===================================================="

mkdir /passy-build/cli
mkdir /passy-build/Passy
mkdir /passy-build/Passy-No-Updates-Popup
export PATH="$PATH:$PWD/submodules/flutter/bin"
git config --global --add safe.directory /Passy
git config --global --add safe.directory /Passy/submodules/flutter
git submodule init
git submodule update

echo "===================================================="
echo "Install flutter"
echo "===================================================="

flutter doctor

echo "===================================================="
echo "Configure flutter"
echo "===================================================="

flutter config --no-analytics

echo "===================================================="
echo "Build Passy CLI"
echo "===================================================="

bash build_cli.sh
cp -r /Passy/build/cli/latest/. /passy-build/cli

echo "===================================================="
echo "Build Passy"
echo "===================================================="

flutter build linux
rm /Passy/build/linux/arm64/release/bundle/lib/libargon2.so
cp /Passy/build/cli/latest/lib/libargon2.so /Passy/build/linux/arm64/release/bundle/lib/
cp -r /Passy/build/linux/arm64/release/bundle/. /passy-build/Passy

echo "===================================================="
echo "Build Passy No Updates Popup"
echo "===================================================="

flutter build linux --dart-define=UPDATES_POPUP_ENABLED=false
rm /Passy/build/linux/arm64/release/bundle/lib/libargon2.so
cp /Passy/build/cli/latest/lib/libargon2.so /Passy/build/linux/arm64/release/bundle/lib/
cp -r /Passy/build/linux/arm64/release/bundle/. /passy-build/Passy-No-Updates-Popup

echo "All Done!"
