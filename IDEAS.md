What functionality I want in Passy:
- Able to register, add and remove an account.
- Able to create and store passwords, notes, ID cards and identities similar to how it is in myki.
- When stored offline, account login unencrypted, password encrypted in SHA 256, and data encrypted under AES of the password.
- Have screen protected from screenshots and blocked in recents view.
- Decentralized synchronization of accounts on local area networks.
- Be able to back up and restore accounts so that they're still synchronized on all devices.
- Be able to switch and add accounts.
- Autofill (desirable, but not required).

Here's how I'll protect the screen: https://stackoverflow.com/questions/54425333/flutter-how-to-hide-or-change-widget-as-seen-in-recent-apps-overview

Here's for the SHA 256 encryption:
https://pub.dev/packages/crypto

And here's the one with AES in it:
https://pub.dev/packages/encrypt

This is how I'll scan the network for devices:
https://pub.dev/packages/network_tools

Here's how I'll do my synchronization once I know my devices:
https://blog.dropzone.dev/writing-server-side-dart-code-3d77c5a915bd

This is how I'll save and load images:
https://stackoverflow.com/questions/28565242/convert-uint8list-to-string-with-dart

What UI I want in Passy:
- Have a UI with tabs.
- Have accent colored numbers in passwords for readability.
- Dark mode.

Here's how the tabs will work:
https://docs.flutter.dev/cookbook/design/tabs

What customization I want in Passy:
- Allow biometric authentication for login.
- Allow screen protection to be toggled.
- Allow account name and password to be changed.
- Allow to choose whether to trust a network or not.

This is for biometric authentication: https://pub.dev/packages/local_auth