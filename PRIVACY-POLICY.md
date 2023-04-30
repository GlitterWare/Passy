# Privacy Policy

## General

GlitterWare (“Passy - Offline password manager with cross-platform synchronization”) values your privacy.

GlitterWare has created this Privacy Policy to demonstrate our commitment to protecting your privacy and to disclose our information and privacy practices for Passy and its services.  
It also describes the choices available to you regarding our use of your personal information and how you can access and update this information.

We reserve the right to change this Policy and will notify you of such changes via our repository.  
If we make any material changes we will notify you by changing the date of the privacy policy at the bottom of this file and in the privacy policy section of `README.md` residing in this repository.

## Security

Passy stores all passwords, pincodes and other information user entered on the device where information was entered and on all of the optionally synchronized devices.  
That means any private or user information was never transfered over the Internet or any other sources or networks unless the user has opted in to the optional synchronization features (see [Synchronization](#synchronization)).

All passwords, passcodes and other information user entered in the "Passy - Offline password manager with cross-platform synchronization" will be additionally encrypted by AES512 SIC encryption with PCKS7 padding.  
When a user’s device is lost or stolen, the data on that device will remain safe for as long as devices's master key, fingerprint, passcode, touchID or faceID is not disclosed.

## Synchronization

If the user has decided to opt in to the synchronization features of our app via pressing the "Host" or "Connect" buttons via in the app's UI, then their private or user information in its encrypted form may be subjected to a one-time transfer via either a Local Area Network or the Internet from one of their personal devices to another device.  
We do not provide any intermediary services for this data transfer and we expect the intermediaries, if any are present, to be chosen by the user and their Internet Service Provider.  
This means that the user data will never arrive to our servers, and may only be transferred between two devices under user's acknowledgement.

Whenever synchronization occurs, host user's device temporarily opens a random, system-provided port for data transfer.  
The port can only be used by one connection and is closed as soon as the synchronization completes, is timed out, or if the host user cancels synchronization by closing the popup that is showing the host device's IP address.  
We are not responsible in case of an undesired data transport from the host device, as it was host device's user's choice to open the port, which they did by pressing the "Host" button, therefore accepting the risk of an undesired connection.

The client user is prompted to input the IP address of the host device on the client device either visually via the QR code or directly via text.  
It is therefore client user's responsibility to enter the correct IP address during synchronization.  
This means that if any data gets sent to an undesired device then we are not responsible for that, as it was a part of user's decision to do that.

Any personal data transferred during synchronization is encrypted with AES512 SIC encryption with PCKS7 padding, and can only be decrypted with user's master password.  
Encrypted personal data will only be transferred once the client device authenticates successfully with the host device.  
The client device sends an encrypted message containing a hello message that the host device needs to confirm, making it impossible to receive the data without knowing the master password.  
This makes data safe to transfer in any networks for as long as user's password is complex enough.

For information on synchronization exclusive to Passy v1.4.0 and higher read [2.0.0+ Synchronization](#200-synchronization).

## 2.0.0+ Synchronization

2.0.0+ synchronization is available under Passy v1.4.0 and higher.  
It uses a hybrid RSA encryption to send and receive entries. 2.0.0+ synchronization is only used if both client and host support it, otherwise old synchronization (see [Synchronization](#synchronization)) is used as a fallback.

Per account, an RSA keypair is generated and stored. Client and host sides exchange their public RSA keys. Host-side then uses the client public key to encrypt a randomly generated password 32 characters in length and sends it to the client. After decrypting the message containing the password, the client-side is ready for further communication. The information exchanged after these steps is encrypted with AES512 SIC encryption with PCKS7 padding using the previously mentioned password.

As of today, RSA encryption coupled with AES512 SIC encryption with PCKS7 padding provides a profound level of security impossible to crack for an average professional attacker.  
Currently, a password generated by the 2.0.0+ synchronization algorithm scores an estimated time to crack of "centuries" over at https://bitwarden.com/password-strength/.

## Information We Collect

GlitterWare does not collect any usage information from customers who use Passy.  
GlitterWare will never have access to your master password, individual records, or any data that is collected and stored locally on user's device by Passy.

Any data collected locally on the device may be stored in the `Passy` directory in user's `Documents` folder or in an isolated environment on that device.  
Neither GlitterWare employees nor any of its contractors have access to this locally stored data.

If GlitterWare is involved in a merger, acquisition, or sale of all or a portion of its assets, you will be notified of any change in ownership or uses of your personal information, as well as any choices you may have regarding your personal information via a prominent notice in this repository's `README.md` and in a popup in the app's login screen.

We will not provide your personal information to companies that do or do not provide services to help us with our business activities such as analytics provider.

Upon request GlitterWare will provide you with information about whether we hold, or process on behalf of a third party, any of your personal information.  
To request this information please contact us at GlitterWare@proton.me.

You may deactivate your Passy app and delete your personal data at any time by removing Passy application from your device, unless you have acquired the app as an AppImage, portable or as an `.exe` installer.  
If you have acquired the app as an AppImage, portable, or as an `.exe` installer, then to delete your personal data you will need to clear the `Passy` directory located in your user's `Documents` folder.

In accordance with the European Union General Data Protection Regulation (GDPR) Passy does not intentionally collect personally identifiable information from nor solicit children under the age of sixteen (16) years of age.

Other than as disclosed in this Privacy Policy, at no time will Passy disclose identifiable personal information to any third parties without your express, written consent.

## Passwords

Your Passy password manager is protected by a master password so that you have secure access to entering and editing personal information.  
It is the user's responsibility to protect their master password. Passy password manager encrypts customer data to protect it from being divulged or accessed by anyone other than the user.  
Neither GlitterWare employees nor any of its contractors can obtain or access user's data from Passy application.  
Neither GlitterWare employees nor any of its contractors will ask you for the data you have entered into your Passy application via mail, email, telephone or any other unsolicited manner.

## Further Questions

If you have further questions about our Privacy Policy, email us at GlitterWare@proton.me.

GlitterWare

1 MAY, 2023
