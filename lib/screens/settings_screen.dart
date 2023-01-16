import 'dart:io';

import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/widgets/passy_about_dialog.dart';
import 'package:passy/screens/security_screen.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/passy_flutter/passy_theme.dart';

import 'automatic_backup_screen.dart';
import 'backup_and_restore_screen.dart';
import 'common.dart';
import 'credentials_screen.dart';
import 'export_and_import_screen.dart';
import 'main_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/settings';

  @override
  State<StatefulWidget> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
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
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: const Text('Donate'),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.money_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => openUrl('https://github.com/sponsors/GlitterWare'),
          )),
          PassyPadding(ThreeWidgetButton(
            center: const Text('Automatic Backup'),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.save_outlined),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => Navigator.pushNamed(
                context, AutomaticBackupScreen.routeName,
                arguments: data.loadedAccount!.username),
          )),
          PassyPadding(ThreeWidgetButton(
            center: const Text('Backup & Restore'),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.save_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => Navigator.pushNamed(
                context, BackupAndRestoreScreen.routeName,
                arguments: data.loadedAccount!.username),
          )),
          PassyPadding(ThreeWidgetButton(
            center: const Text('Export & Import'),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.ios_share_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => Navigator.pushNamed(
                context, ExportAndImportScreen.routeName,
                arguments: data.loadedAccount!.username),
          )),
          if (Platform.isAndroid || Platform.isIOS)
            PassyPadding(ThreeWidgetButton(
                center: const Text('Security'),
                left: const Padding(
                  padding: EdgeInsets.only(right: 30),
                  child: Icon(Icons.lock_rounded),
                ),
                right: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: () =>
                    Navigator.pushNamed(context, SecurityScreen.routeName))),
          PassyPadding(ThreeWidgetButton(
              center: const Text('Credentials'),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.person_outline_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () =>
                  Navigator.pushNamed(context, CredentialsScreen.routeName))),
          PassyPadding(ThreeWidgetButton(
            center: const Text('About'),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.info_outline_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () {
              showDialog(
                  context: context, builder: (ctx) => const PassyAboutDialog());
            },
          )),
        ],
      ),
    );
  }
}
