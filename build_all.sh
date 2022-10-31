#! /bin/bash

user_interrupt(){
  exit
}

trap user_interrupt SIGINT
trap user_interrupt SIGTSTP

echo 'INFO:Building APK'
flutter build apk
echo 'INFO:Building Linux Bundle'
flutter build linux
echo 'INFO:Building Linux AppImage'
echo 'v'$version | ./appimage/appimage_builder
echo ''
echo 'INFO:Finished building version '$version
echo 'Results:'
echo '- Android Apk - '$PWD'/build/app/outputs/flutter-apk/app-release.apk'
echo '- Linux x86_64 Bundle - '$PWD'/build/linux/x64/release/bundle'
echo '- Linux x86_64 AppImage - '$PWD'/build/appimage/Passy-v'$version'-x86_64.AppImage'
