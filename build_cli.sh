#! /bin/bash
cd $(dirname $0)

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
dart compile exe ./lib/passy_cli/bin/passy_cli.dart -o ./build/cli/latest/passy_cli
cp ./lib/passy_cli/bin/passy_cli_native_messaging.sh ./build/cli/latest
cp ./lib/passy_cli/passy_cli_native_messaging.json ./build/cli/latest
cd ./build/cli
echo 'Cloning Argon2...'
if [ -d ./phc-winner-argon2 ]; then rm -rf ./phc-winner-argon2; fi
git clone https://github.com/P-H-C/phc-winner-argon2
cd phc-winner-argon2
make
cp libargon2.so.1 ../latest/lib/libargon2.so
cd ..
echo 'All done.'
echo "Passy CLI: $PWD/latest"

