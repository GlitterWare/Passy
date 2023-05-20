# Passy

#### Want to translate the app to your language? It's simple! Read https://github.com/GlitterWare/Passy/blob/dev/LOCALIZATION.md to get started.

https://glitterware.github.io/Passy

Passy is an offline password manager with cross-platfrom synchronization. 🔒

[![Github Latest Release](https://img.shields.io/github/release/GlitterWare/Passy.svg?logo=github&labelColor=white&logoColor=black&color=7b1fa2&style=for-the-badge)](https://github.com/GlitterWare/Passy/releases/latest) [![F-Droid Latest Release](https://img.shields.io/f-droid/v/com.glitterware.passy.svg?logo=F-Droid&labelColor=white&logoColor=black&color=7b1fa2&style=for-the-badge)](https://f-droid.org/en/packages/com.glitterware.passy) [![Flathub Latest Release](https://img.shields.io/flathub/v/io.github.glitterware.Passy?logo=Flathub&labelColor=white&logoColor=black&color=7b1fa2&style=for-the-badge)](https://flathub.org/apps/details/io.github.glitterware.Passy) [![AUR Latest Release](https://img.shields.io/aur/version/passy?logo=Arch%20Linux&labelColor=white&logoColor=black&color=7b1fa2&style=for-the-badge)](https://aur.archlinux.org/packages/passy)

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-white.svg)](https://snapcraft.io/passy)

Passy is currently being submitted to:
- ✔️ SnapCraft
- ✔️ AppImageHub
- ✔️ F-Droid
- ❌ Google Play Store

Submissions will be finished until June 1 2023.

## Contents

1. [Features](#features)
2. [Installing](#installing)
    - [Windows](#windows)
        - [Installer (Recommended)](#installer-recommended)
        - [Portable](#portable)
    - [Android](#android)
        - [F-Droid](#f-droid)
    - [Linux](#linux)
        - [SnapCraft (Recommended)](#snapcraft-recommended)
        - [Flathub](#flathub)
        - [AUR](#aur)
        - [AppImage](#appimage)
        - [Bundle](#bundle)
3. [Exporting / Backups](#exporting--backups)
    - [Passy (Recommended)](#passy-recommended)
    - [Windows](#windows-1)
    - [Linux](#linux-1)
4. [Building](#building)
    - [Build Options](#build-options)
5. [Privacy Policy](#privacy-policy)
6. [Links & Mentions](#links--mentions)
    - [Store Releases](#store-releases)

## Features

- 🔒 Security – All your information is encrypted in AES and stored offline on your devices, providing highest-tier security.
- 🔄 Synchronization – Share data between separate devices within seconds.
- 🤝 Entry sharing – Send entries to your friends and family.
- 🖐️ Biometrics – Quickly unlock the app using your fingerprint.
- 📚 Multipurpose – Store passwords, payment cards, notes, id cards and identities, all in one place.
- ⚡ Autofill – Quickly fill fields in apps and websites without having to open the app.
- 🧩 Browser extension - Use autofill and add new entries on the fly right from your browser. (See https://github.com/GlitterWare/Passy-Browser-Extension)

## Installing

### Windows

#### Installer (Recommended)

1. Download the installer from [latest release](https://github.com/GlitterWare/Passy/releases/latest). Windows installers are named in format `Passy-<version>-Windows-Installer.exe`;
2. Run the installer and follow the instructions to complete installation.
3. You can now open Passy from the Start menu.

To update Passy, simply repeat same steps with a newer version.

Passy can be removed by running its uninstaller from Programs and Features in the Control Panel. Your data will remain in `C:\Users\<username>\Documents\Passy`.

#### Portable

1. Download the archive from [latest release](https://github.com/GlitterWare/Passy/releases/latest). Windows portable archives are named in format `Passy-<version>-Windows-Portable.zip`.
2. Extract the archive to desired installation location.
3. Run `passy.exe` inside the extracted folder to launch the app.

### Android

#### F-Droid

<a href="https://f-droid.org/en/packages/com.glitterware.passy"><img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png" height="75"></a>

### Linux

#### SnapCraft (Recommended)

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-white.svg)](https://snapcraft.io/passy)

[Get set up for snaps](https://snapcraft.io/docs/installing-snapd).

#### Flathub

[![Flathub Latest Release](https://img.shields.io/flathub/v/io.github.glitterware.Passy?logo=Flathub&labelColor=white&logoColor=black&color=7b1fa2&style=for-the-badge)](https://flathub.org/apps/details/io.github.glitterware.Passy)

#### AUR

[![AUR Latest Release](https://img.shields.io/aur/version/passy?logo=Arch%20Linux&labelColor=white&logoColor=black&color=7b1fa2&style=for-the-badge)](https://aur.archlinux.org/packages/passy)

#### AppImage

It's most comfortable to run AppImages with the [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher/releases/latest) installed. It automatically integrates AppImages and their `.desktop` files into your program launcher for best user experience.

1. Download the archive from [latest release](https://github.com/GlitterWare/Passy/releases/latest). AppImage archives are named in format `Passy-<version>-Linux-AppImage.zip`.
2. Extract the `.AppImage` file to desired installation location.
3. Run the `.AppImage` as a program.

#### Bundle

1. Download the archive from [latest release](https://github.com/GlitterWare/Passy/releases/latest). Linux bundle archives are named in format `Passy-<version>-Linux-Bundle.zip`.
2. Extract the archive to desired installation location.
3. Run `passy` inside the extracted folder to launch the app.

## Exporting / Backups

### Passy (Recommended)

1. Launch the app.
2. Login into the account you wish to back up.
3. Go to account settings by pressing the cogwheel at the right top of the screen.
4. Press `Backup & Restore`.
5. From here you will be able to backup or restore your account data.

### Windows

1. Go to `C:\Users\<username>\Documents`.
2. All Passy data is stored inside the folder named `Passy`, you can make a copy of it elsewhere to backup all accounts if you wish.

### Linux

1. Go to `/home/<username>/Documents`.
2. All Passy data is stored inside the folder named `Passy`, you can make a copy of it elsewhere to backup all accounts if you wish.

## Building

Passy is open-source, feel free to make modifications to it and build it yourself. We're always very glad to see people exploring our projects. 👥

1. [Install Flutter](https://docs.flutter.dev/get-started/install).
2. Clone the repository or [get the source code from the latest Passy release](https://github.com/GlitterWare/Passy/releases/latest).
3. Run `flutter build [subcommand]` to build passy for your system. Passy can be built to `windows`, `linux`, `apk` and `aab`.

### Build Options

Build options are specified with `--dart-define=<option name>=<option value>` (without angle brackets) after the build command.

Available options:
- `UPDATES_POPUP_ENABLED` - Default is `true`, if set to `false`, the update popup will never show up on the login screen.

## Privacy Policy

[1 MAY, 2023](https://github.com/GlitterWare/Passy/blob/main/PRIVACY-POLICY.md)

## Links & Mentions

### Store Releases

- AppImageHub release - https://www.appimagehub.com/p/1906459/.
- AUR releases:
  - (git) https://aur.archlinux.org/packages/passy.
  - (git) https://aur.archlinux.org/packages/passy-git.
- Flathub release - https://flathub.org/apps/details/io.github.glitterware.Passy.
- F-Droid release - https://f-droid.org/en/packages/com.glitterware.passy.
- Snap release - https://snapcraft.io/passy.

#### Made with 💜 by Gleammer.
