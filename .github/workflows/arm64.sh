#! /bin/bash
cd /Passy

echo "===================================================="
echo "Install dependencies"
echo "===================================================="

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev binutils coreutils desktop-file-utils fakeroot fuse libgdk-pixbuf2.0-dev patchelf python3-pip python3-setuptools squashfs-tools strace util-linux zsync libayatana-appindicator3-dev libmpv-dev mpv git file unzip zip wget curl libc6

echo "===================================================="
echo "Configure"
echo "===================================================="

mkdir /passy-build/cli
mkdir /passy-build/Passy
mkdir /passy-build/Passy-No-Updates-Popup
export PATH="$PATH:$PWD/submodules/flutter/bin"
git config --global --add safe.directory /Passy
git config --global --add safe.directory /Passy/submodules/flutter
git config --global --add safe.directory /Passy/submodules/phc-winner-argon2
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
cp -r /Passy/build/cli/latest/. /passy-build/passy-cli

echo "===================================================="
echo "Build Passy"
echo "===================================================="

flutter build linux
cp -r /Passy/build/linux/arm64/release/bundle/. /passy-build/Passy

echo "===================================================="
echo "Build Passy No Updates Popup"
echo "===================================================="

flutter build linux --dart-define=UPDATES_POPUP_ENABLED=false
cp -r /Passy/build/linux/arm64/release/bundle/. /passy-build/Passy-No-Updates-Popup

echo "All Done!"
