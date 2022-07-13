import 'package:flutter/material.dart';
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
  bool _biometricAuthEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Biometric Authentication'),
        centerTitle: true,
      ),
      body: ListView(children: [
        ThreeWidgetButton(
          center: const Text('Biometric Authentication'),
          left: const Icon(Icons.fingerprint_rounded),
          right: Switch(
            value: _biometricAuthEnabled,
            onChanged: (value) => setState(() => _biometricAuthEnabled = value),
          ),
          onPressed: () =>
              setState(() => _biometricAuthEnabled = !_biometricAuthEnabled),
        )
      ]),
    );
  }
}
