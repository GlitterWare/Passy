import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

import 'backup_screen.dart';
import 'restore_screen.dart';
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
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Backup & Restore'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: const Text('Backup'),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.ios_share_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => _onBackupPressed(_username),
          )),
          PassyPadding(ThreeWidgetButton(
            center: const Text('Restore'),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.settings_backup_restore_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: _onRestorePressed,
          )),
        ],
      ),
    );
  }
}
