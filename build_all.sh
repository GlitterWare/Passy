#! /bin/bash

user_interrupt() {
  exit
}

trap user_interrupt SIGINT
trap user_interrupt SIGTSTP

#bash update_version.sh

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

printf 'Build Targets:\n1. Android and Linux. (default)\n2. Android.\n3. Linux.\n'
read -p '?:What do you want to build for? [1/2/3]: ' BUILD_TARGET
BUILD_TARGET=${BUILD_TARGET:-'1'}

read -p '?:Enable updates popup? [y/N]: ' ENABLE_UPDATES_POPUP
ENABLE_UPDATES_POPUP=$(echo ${ENABLE_UPDATES_POPUP:-'n'} | tr '[:upper:]' '[:lower:]')
if [ $ENABLE_UPDATES_POPUP = 'n' ]; then
  ENABLE_UPDATES_POPUP='--dart-define=UPDATES_POPUP_ENABLED=false'
else
  ENABLE_UPDATES_POPUP=''
fi

read -p '?:Build options: ' BUILD_OPTIONS

FLUTTER='flutter --no-version-check --suppress-analytics'

build_linux() {
  echo 'INFO:Building Linux Bundle.'
  echo "Running \`$FLUTTER build linux $ENABLE_UPDATES_POPUP $BUILD_OPTIONS\`" 
  $FLUTTER build linux $ENABLE_UPDATES_POPUP $BUILD_OPTIONS
  cp ./linux_assets/* './build/linux/x64/release/bundle'
  cp './logo.svg' './build/linux/x64/release/bundle/com.glitterware.passy.svg'
  echo 'INFO:Building Linux AppImage.'
  echo 'v'$version | bash appimage/appimage_builder  
}

build_android() {
  echo 'INFO:Building APK.'
  echo "Running \`$FLUTTER build apk $ENABLE_UPDATES_POPUP $BUILD_OPTIONS\`" 
  $FLUTTER build apk $ENABLE_UPDATES_POPUP $BUILD_OPTIONS
}

if [ $BUILD_TARGET = '1' ]; then
  build_android
  build_linux
elif [ $BUILD_TARGET = '2' ]; then
  build_android
elif [ $BUILD_TARGET = '3' ]; then
  build_linux
fi

echo ''
echo 'Builds can be found in:'
echo '- Linux Bundle - '$PWD'/build/linux/x64/release/bundle'
echo '- Linux AppImage - '$PWD'/build/appimage/Passy-Latest-x86_64.AppImage'
echo '- Android Apk - '$PWD'/build/app/outputs/flutter-apk/app-release.apk'
