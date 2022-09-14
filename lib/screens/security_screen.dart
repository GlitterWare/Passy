import 'dart:io';

import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:flutter_secure_screen/flutter_secure_screen.dart';

import 'biometric_auth_screen.dart';

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
    FlutterSecureScreen.singleton
        .setAndroidScreenSecure(loadedAccount.protectScreen);
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
        title: const Text('Security'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          if (Platform.isAndroid || Platform.isIOS)
            PassyPadding(ThreeWidgetButton(
              center: const Text('Biometric authentication'),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.fingerprint_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () {
                Navigator.pushNamed(context, SplashScreen.routeName);
                Navigator.pushReplacementNamed(
                    context, BiometricAuthScreen.routeName);
              },
            )),
          if (Platform.isAndroid)
            PassyPadding(ThreeWidgetButton(
              center: const Text('Protect screen'),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.smart_display),
              ),
              right: Switch(
                value: loadedAccount.protectScreen,
                onChanged: (value) => setProtectScreen(value),
              ),
              onPressed: () => setProtectScreen(!loadedAccount.protectScreen),
            )),
        ],
      ),
    );
  }
}
