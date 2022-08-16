import 'package:flutter/material.dart';

import 'backup_screen.dart';
import 'common.dart';
import 'restore_screen.dart';
import 'theme.dart';
import 'settings_screen.dart';

class BackupAndRestoreScreen extends StatefulWidget {
  const BackupAndRestoreScreen({Key? key}) : super(key: key);

  static const routeName = '${SettingsScreen.routeName}/backupAndRestore';

  @override
  State<StatefulWidget> createState() => _BackupAndRestoreScreen();
}

class _BackupAndRestoreScreen extends State<BackupAndRestoreScreen> {
  void _onBackupPressed(String username) {
    Navigator.pushNamed(context, BackupScreen.routeName, arguments: username);
  }

  void _onRestorePressed() =>
      Navigator.pushNamed(context, RestoreScreen.routeName);

  @override
  Widget build(BuildContext context) {
    final String _username =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: getBackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Backup & Restore'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: entryPadding,
            child: getThreeWidgetButton(
              center: const Text('Backup'),
              left: const Icon(Icons.ios_share_rounded),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () => _onBackupPressed(_username),
            ),
          ),
          Padding(
            padding: entryPadding,
            child: getThreeWidgetButton(
              center: const Text('Restore'),
              left: const Icon(Icons.settings_backup_restore_rounded),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: _onRestorePressed,
            ),
          ),
        ],
      ),
    );
  }
}
