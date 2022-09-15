import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

import 'package:passy/common/assets.dart';
import 'package:passy/screens/main_screen.dart';

import 'backup_and_restore_screen.dart';
import 'log_screen.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  static const routeName = '${BackupAndRestoreScreen.routeName}/backup';

  @override
  State<StatefulWidget> createState() => _BackupScreen();
}

class _BackupScreen extends State<BackupScreen> {
  Future<void> _onPassyBackup(String username) async {
    MainScreen.shouldLockScreen = false;
    try {
      String? _buDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Backup Passy',
        lockParentWindow: true,
      );
      if (_buDir == null) return;
      await data.backupAccount(username: username, outputDirectoryPath: _buDir);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Row(children: const [
            Icon(Icons.save_rounded, color: PassyTheme.darkContentColor),
            SizedBox(width: 20),
            Text('Backup saved'),
          ]),
        ));
    } catch (e, s) {
      if (e is FileSystemException) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Row(children: const [
              Icon(Icons.save_rounded, color: PassyTheme.darkContentColor),
              SizedBox(width: 20),
              Text('Access denied, try another folder'),
            ]),
          ));
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Row(children: const [
              Icon(Icons.save_rounded, color: PassyTheme.darkContentColor),
              SizedBox(width: 20),
              Text('Could not backup'),
            ]),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
                  arguments: e.toString() + '\n' + s.toString()),
            ),
          ));
      }
    }
    MainScreen.shouldLockScreen = true;
  }

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
        title: const Text('Backup'),
        centerTitle: true,
      ),
      body: ListView(children: [
        PassyPadding(ThreeWidgetButton(
          center: const Text('Passy backup'),
          left: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: SvgPicture.asset(
              logoCircleSvg,
              width: 30,
              color: PassyTheme.lightContentColor,
            ),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => _onPassyBackup(_username),
        )),
      ]),
    );
  }
}
