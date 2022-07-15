import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/biometric_storage_data.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/widgets/passy_back_button.dart';
import 'package:passy/widgets/three_widget_button.dart';

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

    void setBioAuthEnabled(bool value) {
      BiometricStorageData _bioData;
      if (value == true) {
        if (getPassyHash(_password).toString() !=
            data.loadedAccount!.passwordHash) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(
              content: Row(children: [
                Icon(Icons.fingerprint_rounded, color: darkContentColor),
                const SizedBox(width: 20),
                const Expanded(child: Text('Wrong password')),
              ]),
            ));
          return;
        }
        _bioData = BiometricStorageData(
            key: data.loadedAccount!.username, password: _password);
        _bioData.save();
      }
      setState(() => data.loadedAccount!.bioAuthEnabled = value);
      data.loadedAccount!.saveSync();
    }

    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Biometric authentication'),
        centerTitle: true,
      ),
      body: ListView(children: [
        ThreeWidgetButton(
          center: const Text('Biometric authentication'),
          left: const Icon(Icons.fingerprint_rounded),
          right: Switch(
            value: data.loadedAccount!.bioAuthEnabled,
            onChanged: (value) => setBioAuthEnabled(value),
          ),
          onPressed: () =>
              setBioAuthEnabled(!data.loadedAccount!.bioAuthEnabled),
        ),
        if (!data.loadedAccount!.bioAuthEnabled)
          Padding(
            padding: entryPadding,
            child: TextFormField(
              controller: TextEditingController(text: _password),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Account password',
              ),
              onChanged: (value) => _password = value,
            ),
          ),
      ]),
    );
  }
}
