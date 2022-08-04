#! /bin/bash

export file='pubspec.yaml'
export version=''

while read -r line; do
    if [[ $line == *'version: '* ]]; then
        export version=${line:9:${#line}}
        break
    fi
done <$file 

if [[ ${#version} == 0 ]]; then
    read -p "? Could not detect version. Enter version manually [Eg: 1.0.0]: " appVersion
else
    echo 'INFO:Version detected:'$version
fi

echo 'INFO:Building APK'
flutter build apk
echo 'INFO:Building Linux Bundle'
flutter build linux
echo 'INFO:Building Linux AppImage'
echo 'v'$version | ./appimage/appimage_builder
echo ''
echo 'INFO:Finished building version '$version
echo 'Results:'
echo '- Android Apk - ./build/app/outputs/flutter-apk/app-release.apk'
echo '- Linux Bundle - ./build/linux/release/bundle'
echo '- Linux AppImage - ./build/appimage/Passy-v'$version'-x86_64.AppImage'