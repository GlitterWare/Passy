import 'dart:io';

import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/key_derivation_type.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/key_derivation_screen.dart';
import 'package:flutter_secure_screen/flutter_secure_screen.dart';

import 'biometric_auth_screen.dart';
import 'change_password_screen.dart';
import 'change_username_screen.dart';
import 'common.dart';

class SecurityScreen extends StatefulWidget {
  static const routeName = '/security';

  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SecurityScreen();
}

class _SecurityScreen extends State<SecurityScreen> {
  final LoadedAccount loadedAccount = data.loadedAccount!;

  void setProtectScreen(bool value) {
    setState(() {
      loadedAccount.protectScreen = value;
    });
    if (Platform.isAndroid) {
      FlutterSecureScreen.singleton
          .setAndroidScreenSecure(loadedAccount.protectScreen);
    }
    loadedAccount.saveSettings();
  }

  void setAutoScreenLock(bool value) {
    setState(() {
      loadedAccount.autoScreenLock = value;
    });
    loadedAccount.saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.security),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          if (Platform.isAndroid || Platform.isIOS)
            PassyPadding(ThreeWidgetButton(
              center: Text(localizations.biometricAuthentication),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.fingerprint_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () =>
                  Navigator.pushNamed(context, BiometricAuthScreen.routeName),
            )),
          if (Platform.isAndroid)
            PassyPadding(ThreeWidgetButton(
              center: Text(localizations.protectScreen),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.smart_display),
              ),
              right: Switch(
                activeColor: Colors.greenAccent,
                value: loadedAccount.protectScreen,
                onChanged: (value) => setProtectScreen(value),
              ),
              onPressed: () => setProtectScreen(!loadedAccount.protectScreen),
            )),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.automaticScreenLock),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.security),
            ),
            right: Switch(
              activeColor: Colors.greenAccent,
              value: loadedAccount.autoScreenLock,
              onChanged: (value) => setAutoScreenLock(value),
            ),
            onPressed: () => setAutoScreenLock(!loadedAccount.autoScreenLock),
          )),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.changeUsername),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.person_outline_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, ChangeUsernameScreen.routeName),
          )),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.changePassword),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.lock_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, ChangePasswordScreen.routeName),
          )),
          PassyPadding(ThreeWidgetButton(
            color:
                (loadedAccount.keyDerivationType == KeyDerivationType.none) &&
                        recommendKeyDerivation
                    ? const Color.fromRGBO(255, 82, 82, 1)
                    : null,
            center: Text(localizations.keyDerivation),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.key_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, KeyDerivationScreen.routeName)
                    .then(
              (value) => setState(() {}),
            ),
          )),
        ],
      ),
    );
  }
}
