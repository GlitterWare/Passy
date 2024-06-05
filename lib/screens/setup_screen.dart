import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/key_derivation_type.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/backup_and_restore_screen.dart';
import 'package:passy/screens/import_screen.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/security_screen.dart';

import 'common.dart';

class SetupScreen extends StatefulWidget {
  static const String routeName = '/setupScreen';

  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SetupScreen();
}

class _SetupScreen extends State<SetupScreen> {
  final LoadedAccount _account = data.loadedAccount!;

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
            color: PassyTheme.lightContentColor,
            center: Text(
              localizations.done,
              style: const TextStyle(color: PassyTheme.darkContentColor),
            ),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(
                Icons.check_rounded,
                color: PassyTheme.darkContentColor,
              ),
            ),
            right: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: PassyTheme.darkContentColor,
            ),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, MainScreen.routeName),
          )),
        ],
      ),
    );
  }
}
