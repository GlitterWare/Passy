# Snap Store Instructions

<details>

<summary>Contents</summary>

## Contents

1. [Installing Passy](#installing-passy)
   - [The GUI Way (Recommended)](#the-gui-way-recommended)
   - [Command-line](#command-line)
3. [Enabling Browser Extension Support](#enabling-browser-extension-support)
   - [The GUI Way (Recommended)](#the-gui-way-recommended-1)
   - [Command-line](#command-line-1)
   - [What permissions am I granting?](#what-permissions-am-i-granting)

</details>

## Installing Passy

Some popular Linux distributions (Ubuntu, Manjaro, KDE Neon) come with Snap pre-installed. If you do not have Snap installed on your system you can see [Passy latest release](https://github.com/GlitterWare/Passy/releases/latest) for Linux AppImage and Bundle downloads, use our [Flathub package](https://flathub.org/apps/details/io.github.glitterware.Passy) or check https://snapcraft.io/docs/installing-snapd for Snap installation guide.

### The GUI Way (Recommended)

With the Ubuntu/Debian store app installed, you can use it to install Passy.

If you are interested in using **Passy browser extension**, don't forget to check the [Enabling Browser Extension Support](#enabling-browser-extension-support) section after the installation is complete.

1. Open the Ubuntu/Debian store app (if you can't find it in your application drawer, see [Command-line](#command-line)):  
![Open the Ubuntu/Debian store app](https://github.com/GlitterWare/Passy/assets/101527589/ad9266d4-1800-4ff1-a6ce-e88a99e6ea3d)
2. Find Passy in Ubuntu/Debian store app and click on the search result:  
![Finding Passy in Ubuntu/Debian store app](https://github.com/GlitterWare/Passy/assets/101527589/c1ddb72c-82c6-433b-b62b-463a3b5723e7)
3. Once on Passy's application page, press the `Install` button:  
![Press `Install` to install Passy](https://github.com/GlitterWare/Passy/assets/101527589/fc2dcfde-b64b-4d77-b882-8038adcf49bc)
4. When the installation completes, you should be able to find Passy in your application drawer.
5. [Enable browser extension support](#enabling-browser-extension-support) (Optional).

<details>

<summary>Command-line</summary>

### Command-line

To install Passy via your terminal, use the following command:
```sh
snap install passy
```

</details>

## Enabling Browser Extension Support

By default, Passy Snap package requires additional permissions to allow for the browser extension to work.

### The GUI Way (Recommended)

If you have Ubuntu/Debian store app installed, you can make use of it to enable browser extension support.

1. On Passy's application page in Ubuntu/Debian store, use the `Permissions` button:  
![Use the `Permissions` button in Ubuntu/Debian store app](https://github.com/GlitterWare/Passy/assets/101527589/4a34b7fa-99e2-4341-8ae9-561cce17dbee)
2. Click the knob next to `personal-files` to toggle it:  
![Toggle the personal files interface permission knob](https://github.com/GlitterWare/Passy/assets/101527589/5d1a4501-e4f9-4ee5-8264-d0385b7ecc0d)
3. You may need to enter your system user password to allow the Snap client to connect the interface:  
![Enter your system user password to connect the interface](https://github.com/GlitterWare/Passy/assets/101527589/b4c476e1-8710-4ca9-91e1-2d68f62a9874)

<details>

<summary>Command-line</summary>

### Command-line

Granting the permission via the terminal is a one-liner, execute the following:
```sh
snap connect passy:native-messaging-hosts
```

</details>

### What permissions am I granting?

The following is the `passy:native-messaging-hosts` plug, including the list of all allowed directories:

```yaml
native-messaging-hosts:
  interface: personal-files
  write:
  - $HOME/.mozilla/native-messaging-hosts
  - $HOME/.config/microsoft-edge/NativeMessagingHosts
  - $HOME/.config/google-chrome/NativeMessagingHosts
  - $HOME/.config/chromium/NativeMessagingHosts
  - $HOME/.config/BraveSoftware/Brave-Browser/NativeMessagingHosts
```
