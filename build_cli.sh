#! /bin/bash
cd "$(dirname "$0")"

user_interrupt() {
  exit
}

trap user_interrupt SIGINT
trap user_interrupt SIGTSTP

if [ ! -d ./build ]; then mkdir ./build; fi
if [ ! -d ./build/cli ]; then mkdir ./build/cli; fi
if [ -d ./build/cli/latest ]; then rm -rf ./build/cli/latest; fi
mkdir ./build/cli/latest
mkdir ./build/cli/latest/lib
flutter pub get
echo 'Building Passy CLI...'
dart compile exe --suppress-analytics ./lib/passy_cli/bin/passy_cli.dart -o ./build/cli/latest/passy_cli
cp ./lib/passy_cli/bin/passy_cli_native_messaging.sh ./build/cli/latest
cp ./lib/passy_cli/passy_cli_native_messaging.json ./build/cli/latest
cd ./build/cli
echo 'Cloning Argon2...'
git submodule update --init --recursive
if [ -d ./phc-winner-argon2 ]; then rm -rf ./phc-winner-argon2; fi
make -C ../../submodules/phc-winner-argon2
cp ../../submodules/phc-winner-argon2/libargon2.so.1 ./latest/lib/libargon2.so
echo 'All done.'
echo "Passy CLI: $PWD/latest"

