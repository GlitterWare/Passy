#! /bin/bash

user_interrupt(){
  exit
}

trap user_interrupt SIGINT
trap user_interrupt SIGTSTP

read -p "? Version [Eg: 1.0.0]: " appVersion
read -p "? Build options: " buildOptions

echo 'INFO:Building APK'
flutter build apk $buildOptions
echo 'INFO:Building Linux Bundle'
flutter build linux $buildOptions
cp ./linux_meta/* './build/linux/x64/release/bundle'
cp './logo.svg' './build/linux/x64/release/bundle/com.glitterware.passy.svg'
echo 'INFO:Building Linux AppImage'
echo 'v'$appVersion | ./appimage/appimage_builder
echo ''
echo 'Results:'
echo '- Android Apk - '$PWD'/build/app/outputs/flutter-apk/app-release.apk'
echo '- Linux x86_64 Bundle - '$PWD'/build/linux/x64/release/bundle'
echo '- Linux x86_64 AppImage - '$PWD'/build/appimage/Passy-v'$appVersion'-x86_64.AppImage'
