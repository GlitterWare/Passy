#! /bin/bash

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

export newVersion=''
read -p '? Enter new version [Default: '$version']: ' newVersion
if [[ ${#newVersion} == 0 ]]; then
  newVersion=$version
fi

echo 'INFO:Changing version '$version' to '$newVersion

echo 'INFO:Changing version in `lib/passy_data/common.dart`.'
sed -i 's/passyVersion = '\'$version\'\;'/passyVersion = '\'$newVersion\'\;'/' ./lib/passy_data/common.dart
echo 'INFO:Changing version in `pubspec.yaml`.'
sed -i 's/version: '$version'/version: '$newVersion'/' ./pubspec.yaml
echo 'INFO:Changing version in AppStream metadata.'
sed -i 's/version="v'$version'"/version="v'$newVersion'"/' ./linux_assets/com.glitterware.passy.appdata.xml
echo 'INFO:Changing version in `passy.iss`.'
sed -i 's/"'$version'"/"'$newVersion'"/' ./passy.iss
echo 'INFO:Changing version in `snap/snapcraft.yaml`.'
sed -i 's/version: '\'v$version\''/version: '\'v$newVersion\''/' ./snap/snapcraft.yaml
