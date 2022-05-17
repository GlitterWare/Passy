import 'package:flutter/material.dart';
import 'package:passy/widgets/back_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = '/main/settings';

  @override
  State<StatefulWidget> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Settings'),
        centerTitle: true,
      ),
    );
  }
}
