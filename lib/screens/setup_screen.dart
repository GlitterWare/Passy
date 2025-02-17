import 'dart:io';

import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/key_derivation_type.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'common.dart';
import 'main_screen.dart';
import 'theme_screen.dart';
import 'security_screen.dart';
import 'import_screen.dart';
import 'backup_and_restore_screen.dart';

class SetupScreen extends StatefulWidget {
  static const String routeName = '/setupScreen';

  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SetupScreen();
}

class _SetupScreen extends State<SetupScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  void setMinimizeToTray(bool value) {
    if (value) {
      if (!trayEnabled) toggleTray(context);
    } else {
      if (trayEnabled) toggleTray(context);
    }
    setState(() {
      _account.minimizeToTray = value;
    });
    _account.saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.accountSetup),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: localizations.done,
        child: const Icon(Icons.check_rounded),
        onPressed: () =>
            Navigator.pushReplacementNamed(context, MainScreen.routeName),
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.import),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.download_for_offline_outlined),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, ImportScreen.routeName),
          )),
          PassyPadding(ThreeWidgetButton(
              center: Text(localizations.security),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.lock_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              color: (_account.keyDerivationType == KeyDerivationType.none) &&
                      recommendKeyDerivation
                  ? const Color.fromRGBO(255, 82, 82, 1)
                  : null,
              onPressed: () =>
                  Navigator.pushNamed(context, SecurityScreen.routeName)
                      .then((value) => setState(() {})))),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.automaticBackup),
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
            center: Text(localizations.theme),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.colorize),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, ThemeScreen.routeName),
          )),
          if (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
            PassyPadding(ThreeWidgetButton(
              center: Text(localizations.minimizeToTray),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.circle),
              ),
              right: Switch(
                //activeColor: Colors.deepPurpleAccent,
                value: _account.minimizeToTray,
                onChanged: (value) => setMinimizeToTray(value),
              ),
              onPressed: () => setMinimizeToTray(!_account.minimizeToTray),
            )),
          PassyPadding(ThreeWidgetButton(
            color: PassyTheme.of(context).highlightContentColor,
            center: Text(
              localizations.done,
              style: TextStyle(color: PassyTheme.of(context).contentColor),
            ),
            left: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Icon(
                Icons.check_rounded,
                color: PassyTheme.of(context).contentColor,
              ),
            ),
            right: Icon(
              Icons.arrow_forward_ios_rounded,
              color: PassyTheme.of(context).contentColor,
            ),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, MainScreen.routeName),
          )),
        ],
      ),
    );
  }
}
