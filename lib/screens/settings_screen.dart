import 'package:flutter/material.dart';
import 'package:passy/screens/backup_and_restore_screen.dart';
import 'package:passy/widgets/elevated_iconed_button.dart';
import 'package:passy/widgets/passy_back_button.dart';

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
      body: ListView(children: [
        ElevatedIconedButton(
          body: const Text('Backup & Restore'),
          leftIcon: const Icon(Icons.save_rounded),
          rightIcon: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () =>
              Navigator.pushNamed(context, BackupAndRestoreScreen.routeName),
        ),
      ]),
    );
  }
}
