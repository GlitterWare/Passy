import 'package:flutter/material.dart';
import 'package:flutter_locker/flutter_locker.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/biometric_storage_data.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/passy_flutter/passy_theme.dart';

import 'settings_screen.dart';

class BiometricAuthScreen extends StatefulWidget {
  static const routeName = '${SettingsScreen.routeName}/bioAuth';

  const BiometricAuthScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BiometricAuthScreen();
}

class _BiometricAuthScreen extends State<BiometricAuthScreen> {
  @override
  Widget build(BuildContext context) {
    String _password = '';

    void setBioAuthEnabled(bool value) async {
      BiometricStorageData _bioData;
      String _username = data.loadedAccount!.username;
      if (value == true) {
        if (getPassyHash(_password).toString() !=
            data.loadedAccount!.passwordHash) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(
              content: Row(children: [
                Icon(Icons.fingerprint_rounded,
                    color: PassyTheme.darkContentColor),
                const SizedBox(width: 20),
                const Expanded(child: Text('Wrong password')),
              ]),
            ));
          return;
        }
        _bioData = BiometricStorageData(key: _username, password: _password);
        try {
          await _bioData.save();
        } catch (e) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(
              content: Row(children: [
                Icon(Icons.fingerprint_rounded,
                    color: PassyTheme.darkContentColor),
                const SizedBox(width: 20),
                const Expanded(child: Text('Couldn\'t authenticate')),
              ]),
            ));
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
        title: const Text('Biometric authentication'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: const Text('Biometric authentication'),
            left: const Icon(Icons.fingerprint_rounded),
            right: Switch(
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
              decoration: const InputDecoration(
                labelText: 'Account password',
              ),
              onChanged: (value) => setState(() => _password = value),
            )),
        ],
      ),
    );
  }
}
