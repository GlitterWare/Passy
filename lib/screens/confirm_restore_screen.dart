import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/restore_screen.dart';

import 'log_screen.dart';

class ConfirmRestoreScreen extends StatefulWidget {
  static const String routeName = '${RestoreScreen.routeName}/confirm';

  const ConfirmRestoreScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfirmRestoreScreen();
}

class _ConfirmRestoreScreen extends State<ConfirmRestoreScreen> {
  @override
  Widget build(BuildContext context) {
    String _path = ModalRoute.of(context)!.settings.arguments as String;
    return ConfirmStringScreen(
        title: const Text('Passy restore'),
        message: PassyPadding(RichText(
          text: const TextSpan(
            text: 'If the account you\'re restoring already exists, then ',
            children: [
              TextSpan(
                text: 'its current data will be lost ',
                style: TextStyle(color: PassyTheme.lightContentSecondaryColor),
              ),
              TextSpan(
                  text:
                      'and replaced with the backup.\n\nEnter account password to restore.'),
            ],
          ),
          textAlign: TextAlign.center,
        )),
        labelText: 'Enter password',
        obscureText: true,
        confirmIcon: const Icon(Icons.settings_backup_restore_rounded),
        onBackPressed: (context) => Navigator.pop(context),
        onConfirmPressed: (context, value) {
          data.restoreAccount(_path, encrypter: getPassyEncrypter(value)).then(
            (value) {
              Navigator.popUntil(context,
                  (route) => route.settings.name == MainScreen.routeName);
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
            onError: (e, s) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Row(children: const [
                      Icon(Icons.settings_backup_restore_rounded,
                          color: PassyTheme.darkContentColor),
                      SizedBox(width: 20),
                      Text('Could not restore account'),
                    ]),
                    action: SnackBarAction(
                      label: 'Details',
                      onPressed: () => Navigator.pushNamed(
                          context, LogScreen.routeName,
                          arguments: e.toString() + '\n' + s.toString()),
                    ),
                  ),
                );
            },
          );
        });
  }
}
