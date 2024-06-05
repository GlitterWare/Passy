import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/backup_and_restore_screen.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/main_screen.dart';

import 'log_screen.dart';

class ConfirmRestoreScreen extends StatefulWidget {
  static const String routeName =
      '${BackupAndRestoreScreen.routeName}/confirmRestore';

  const ConfirmRestoreScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfirmRestoreScreen();
}

class _ConfirmRestoreScreen extends State<ConfirmRestoreScreen> {
  @override
  Widget build(BuildContext context) {
    String _path = ModalRoute.of(context)!.settings.arguments as String;
    return ConfirmStringScaffold(
        title: Text(localizations.passyRestore),
        message: PassyPadding(Text.rich(
          formattedTextParser.parse(
              text:
                  '${localizations.confirmRestoreMsg}\n\n${localizations.enterAccountPasswordToRestore}'),
          textAlign: TextAlign.center,
        )),
        labelText: localizations.enterPassword,
        obscureText: true,
        confirmIcon: const Icon(Icons.settings_backup_restore_rounded),
        onBackPressed: (context) => Navigator.pop(context),
        onConfirmPressed: (context, value) {
          data.restoreAccount(_path, password: value).then(
            (value) {
              Navigator.popUntil(context,
                  (route) => route.settings.name == MainScreen.routeName);
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
            onError: (e, s) {
              showSnackBar(
                message: localizations.couldNotRestoreAccount,
                icon: const Icon(Icons.settings_backup_restore_rounded,
                    color: PassyTheme.darkContentColor),
                action: SnackBarAction(
                  label: localizations.details,
                  onPressed: () => Navigator.pushNamed(
                      context, LogScreen.routeName,
                      arguments: e.toString() + '\n' + s.toString()),
                ),
              );
            },
          );
        });
  }
}
