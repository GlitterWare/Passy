import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/main_screen.dart';

import 'import_screen.dart';
import 'log_screen.dart';

class ConfirmImportScreen extends StatefulWidget {
  static const String routeName = '${ImportScreen.routeName}/confirm';

  const ConfirmImportScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfirmImportScreen();
}

class _ConfirmImportScreen extends State<ConfirmImportScreen> {
  String _path = '';

  Future<void> _onConfirmPressed(BuildContext context, String value) async {
    try {
      await data.importAccount(_path, encrypter: getPassyEncrypter(value));
      Navigator.popUntil(
          context, (route) => route.settings.name == MainScreen.routeName);
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    } catch (e, s) {
      showSnackBar(
        context,
        message: localizations.couldNotImportAccount,
        icon: const Icon(Icons.download_for_offline_outlined,
            color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _path = ModalRoute.of(context)!.settings.arguments as String;
    return ConfirmStringScaffold(
        title: Text(localizations.passyImport),
        message: PassyPadding(RichText(
          text: TextSpan(
            text: localizations.confirmImport1,
            children: [
              TextSpan(
                text: localizations.confirmImport2Highlighted,
                style: const TextStyle(
                    color: PassyTheme.lightContentSecondaryColor),
              ),
              TextSpan(
                  text:
                      '${localizations.confirmImport3}.\n\n${localizations.enterAccountPasswordToImport}.'),
            ],
          ),
          textAlign: TextAlign.center,
        )),
        labelText: localizations.enterPassword,
        obscureText: true,
        confirmIcon: const Icon(Icons.download_for_offline_outlined),
        onBackPressed: (context) => Navigator.pop(context),
        onConfirmPressed: _onConfirmPressed);
  }
}
