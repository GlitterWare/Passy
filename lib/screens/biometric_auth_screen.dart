import 'package:flutter/material.dart';
import 'package:flutter_locker/flutter_locker.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/biometric_storage_data.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/screens/common.dart';

import 'settings_screen.dart';

class BiometricAuthScreen extends StatefulWidget {
  static const routeName = '${SettingsScreen.routeName}/bioAuth';

  const BiometricAuthScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BiometricAuthScreen();
}

class _BiometricAuthScreen extends State<BiometricAuthScreen> {
  String _password = '';

  @override
  Widget build(BuildContext context) {
    void setBioAuthEnabled(bool value) async {
      BiometricStorageData _bioData;
      String _username = data.loadedAccount!.username;
      if (value == true) {
        if (getPassyHash(_password).toString() !=
            data.loadedAccount!.passwordHash) {
          showSnackBar(context,
              message: localizations.incorrectPassword,
              icon: const Icon(Icons.lock_rounded,
                  color: PassyTheme.darkContentColor));
          return;
        }
        _bioData = BiometricStorageData(key: _username, password: _password);
        try {
          await _bioData.save();
        } catch (e) {
          showSnackBar(context,
              message: localizations.couldNotAuthenticate,
              icon: const Icon(Icons.fingerprint_rounded,
                  color: PassyTheme.darkContentColor));
          return;
        }
      } else {
        await FlutterLocker.delete(_username);
      }
      setState(() => data.loadedAccount!.bioAuthEnabled = value);
      data.loadedAccount!.saveSync();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.biometricAuthentication),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.biometricAuthentication),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.fingerprint_rounded),
            ),
            right: Switch(
              activeColor: Colors.greenAccent,
              value: data.loadedAccount!.bioAuthEnabled,
              onChanged: (value) => setBioAuthEnabled(value),
            ),
            onPressed: () =>
                setBioAuthEnabled(!data.loadedAccount!.bioAuthEnabled),
          )),
          if (!data.loadedAccount!.bioAuthEnabled)
            PassyPadding(TextFormField(
              initialValue: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: localizations.accountPassword,
              ),
              onChanged: (value) => setState(() => _password = value),
            )),
        ],
      ),
    );
  }
}
