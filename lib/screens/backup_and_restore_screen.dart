import 'package:flutter/material.dart';
import 'package:passy/screens/backup_screen.dart';
import 'package:passy/screens/restore_screen.dart';
import 'package:passy/widgets/three_widget_button.dart';
import 'package:passy/widgets/passy_back_button.dart';

import 'settings_screen.dart';

class BackupAndRestoreScreen extends StatefulWidget {
  const BackupAndRestoreScreen({Key? key}) : super(key: key);

  static const routeName = '${SettingsScreen.routeName}/backupAndRestore';

  @override
  State<StatefulWidget> createState() => _BackupAndRestoreScreen();
}

class _BackupAndRestoreScreen extends State<BackupAndRestoreScreen> {
  @override
  Widget build(BuildContext context) {
    final String _username =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Backup & Restore'),
        centerTitle: true,
      ),
      body: ListView(children: [
        ThreeWidgetButton(
          center: const Text('Backup'),
          left: const Icon(Icons.ios_share_rounded),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => Navigator.pushNamed(context, BackupScreen.routeName,
              arguments: _username),
        ),
        ThreeWidgetButton(
          center: const Text('Restore'),
          left: const Icon(Icons.settings_backup_restore_rounded),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () =>
              Navigator.pushNamed(context, RestoreScreen.routeName),
        ),
      ]),
    );
  }
}
