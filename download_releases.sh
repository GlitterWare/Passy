#! /bin/bash
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
  -n linux-appimage \
  -n linux-bundle \
  -n linux-snap \
  -n windows-exe-installer \
  -n windows-portable \
  -n passy-cli-linux-arm64 \
  -n passy-cli-linux-armv7 \
  -n passy-linux-arm64
echo 'Done.'

echo 'Preparing Passy Snap...'
cp linux-snap/* .
echo 'Preparing Passy CLI Linux ARM64...'
cp passy-cli-linux-arm64/Passy-CLI-Linux-ARM64.zip ./Passy-CLI-v$version-Linux-ARM64.zip
echo 'Preparing Passy CLI Linux ARMv7...'
cp passy-cli-linux-armv7/Passy-CLI-Linux-ARMv7.zip ./Passy-CLI-v$version-Linux-ARMv7.zip
echo 'Preparing Passy Android Apk...'
cp android/Passy-Android.apk ./Passy-v$version.apk
zip -9 ./Passy-v$version-Android-Apk.zip Passy-v$version.apk 
rm Passy-v$version.apk
echo 'Preparing Passy Linux ARM64...'
cp passy-linux-arm64/Passy-Linux-ARM64.zip ./Passy-v$version-Linux-ARM64-Bundle.zip
echo 'Preparing Passy Linux Bundle...'
cp linux-bundle/Passy-Linux-Bundle.zip ./Passy-v$version-Linux-Bundle.zip
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

echo 'All done.'
echo "Passy releases: $PWD/build/gh_releases"
