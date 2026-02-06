#! /bin/bash
set -e
cd "$(dirname "$0")"

user_interrupt() {
  exit
}

trap user_interrupt SIGINT
trap user_interrupt SIGTSTP

export version=''

while read -r line; do
  if [[ $line == *'version: '* ]]; then
    export version=$(echo ${line:9:${#line}} | cut -d '+' -f1)
    break
  fi
done <'./pubspec.yaml'

if [[ ${#version} == 0 ]]; then
  read -p '? Could not detect current version. Enter current version manually [Eg: 1.0.0]: ' version
else
  echo 'INFO:Version detected:'$version
fi

if [ -d ./build/gh_releases ]; then rm -rf ./build/gh_releases; fi
mkdir -p ./build/gh_releases
cd ./build/gh_releases

echo 'Downloading latest release artifacts...'
gh run download \
  -n android \
  -n cli-linux \
  -n cli-linux-arm64 \
  -n cli-linux-armv7 \
  -n linux-appimage \
  -n linux-arm64-appimage \
  -n linux-arm64-bundle \
  -n linux-arm64-bundle-no-updates-popup \
  -n linux-bundle \
  -n linux-bundle-no-updates-popup \
  -n linux-snap \
  -n linux-snap-arm64 \
  -n windows-exe-installer \
  -n windows-portable
echo 'Done.'

echo 'Preparing Passy Snap...'
cp linux-snap/* .
echo 'Preparing Passy Snap ARM64...'
cp linux-snap-arm64/* .
echo 'Preparing Passy CLI Linux...'
cp cli-linux/Passy-CLI-Linux.zip ./Passy-CLI-v$version-Linux.zip
echo 'Preparing Passy CLI Linux ARM64...'
cp cli-linux-arm64/Passy-CLI-Linux-ARM64.zip ./Passy-CLI-v$version-Linux-ARM64.zip
echo 'Preparing Passy CLI Linux ARMv7...'
cp cli-linux-armv7/Passy-CLI-Linux-ARMv7.zip ./Passy-CLI-v$version-Linux-ARMv7.zip
echo 'Preparing Passy Android Apk...'
cp android/Passy-Android.apk ./Passy-v$version.apk
zip -9 ./Passy-v$version-Android-Apk.zip Passy-v$version.apk 
rm Passy-v$version.apk
echo 'Preparing Passy Linux ARM64...'
cp linux-arm64-bundle/Passy-Linux-ARM64-Bundle.zip ./Passy-v$version-Linux-ARM64-Bundle.zip
cp linux-arm64-bundle-no-updates-popup/Passy-Linux-ARM64-Bundle.zip ./Passy-v$version-Linux-ARM64-Bundle-No-Updates-Popup.zip
echo 'Preparing Passy Linux Bundle...'
cp linux-bundle/Passy-Linux-Bundle.zip ./Passy-v$version-Linux-Bundle.zip
unzip ./Passy-v$version-Linux-Bundle.zip
cp linux-bundle-no-updates-popup/Passy-Linux-Bundle.zip ./Passy-v$version-Linux-Bundle-No-Updates-Popup.zip
echo 'Preparing Passy Windows Installer...'
cp windows-exe-installer/Passy-Windows-Installer.exe ./Passy-v$version-Windows-Installer.exe
echo 'Preparing Passy Windows Portable...'
cd windows-portable
zip -9 -r ../Passy-v$version-Windows-Portable.zip Passy
cd ..
echo 'Preparing Passy Linux AppImage...'
cp linux-appimage/Passy-Linux-AppImage.zip .
unzip Passy-Linux-AppImage.zip
rm Passy-Linux-AppImage.zip
chmod +x Passy-Latest-x86_64.AppImage
mv Passy-Latest-x86_64.AppImage Passy-v$version-x86-64.AppImage
echo 'Preparing Passy Linux ARM64 AppImage...'
cp linux-arm64-appimage/Passy-Linux-ARM64-AppImage.zip .
unzip Passy-Linux-ARM64-AppImage.zip
rm Passy-Linux-ARM64-AppImage.zip
chmod +x Passy-Latest-aarch64.AppImage
mv Passy-Latest-aarch64.AppImage Passy-v$version-aarch64.AppImage

echo 'All done.'
echo "Passy releases: $PWD/build/gh_releases"
