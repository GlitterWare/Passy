#! /bin/bash
cd /Passy

echo "===================================================="
echo "Install dependencies"
echo "===================================================="

apt-get update
apt-get -y install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev binutils coreutils desktop-file-utils fakeroot fuse libgdk-pixbuf2.0-dev patchelf python3-pip python3-setuptools squashfs-tools strace util-linux zsync git file unzip zip wget curl libc6

echo "===================================================="
echo "Configure"
echo "===================================================="

export PATH="$PATH:$PWD/submodules/flutter/bin"
git config --global --add safe.directory /Passy
git config --global --add safe.directory /Passy/submodules/flutter
git submodule init
git submodule update

echo "===================================================="
echo "Install dart"
echo "===================================================="

mkdir submodules/flutter/bin/cache
flutter doctor
export LAST_PWD=$PWD
cd submodules/flutter/bin/cache
rm -rf dart-sdk
wget https://storage.googleapis.com/dart-archive/channels/stable/release/3.3.1/sdk/dartsdk-linux-arm-release.zip
unzip dartsdk-linux-arm-release.zip
rm dartsdk-linux-arm-release.zip
cd $LAST_PWD

echo "===================================================="
echo "Install flutter"
echo "===================================================="

flutter clean
flutter doctor

echo "===================================================="
echo "Configure flutter"
echo "===================================================="

flutter config --no-analytics

echo "===================================================="
echo "Build Passy CLI"
echo "===================================================="

bash build_cli.sh

echo "===================================================="
echo "Build Passy"
echo "===================================================="

flutter build linux
rm /Passy/build/linux/arm64/release/bundle/lib/libargon2.so
cp /Passy/build/cli/latest/lib/libargon2.so /Passy/build/linux/arm64/release/bundle/lib/

echo "===================================================="
echo "Prepare releases"
echo "===================================================="

cd /passy-build
mkdir cli
cp -r /Passy/build/cli/latest/. cli
mkdir Passy
cp -r /Passy/build/linux/arm64/release/bundle/. Passy

