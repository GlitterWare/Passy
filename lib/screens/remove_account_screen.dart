import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';

import 'add_account_screen.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

class RemoveAccountScreen extends StatefulWidget {
  static const String routeName = '${LoginScreen.routeName}/removeAccount';

  const RemoveAccountScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RemoveAccountScreen();
}

class _RemoveAccountScreen extends State<RemoveAccountScreen> {
  @override
  Widget build(BuildContext context) {
    String _username = ModalRoute.of(context)!.settings.arguments as String;
    return ConfirmStringScaffold(
      title: Text(localizations.removeAccount),
      message: PassyPadding(Text.rich(
        TextSpan(text: localizations.confirmRemoveAccount1, children: [
          TextSpan(
            text: '\'$_username\' ',
            style:
                const TextStyle(color: PassyTheme.lightContentSecondaryColor),
          ),
          TextSpan(
              text:
                  '${localizations.confirmRemoveAccount2}.\n\n${localizations.confirmRemoveAccount3}'),
          TextSpan(
            text: localizations.confirmRemoveAccount4Highlighted,
            style:
                const TextStyle(color: PassyTheme.lightContentSecondaryColor),
          ),
          const TextSpan(text: '.'),
        ]),
        textAlign: TextAlign.center,
      )),
      labelText: localizations.confirmUsername,
      confirmIcon: const Icon(Icons.delete_outline_rounded),
      onBackPressed: (context) => Navigator.pop(context),
      onConfirmPressed: (context, value) {
        if (value != _username) {
          showSnackBar(context,
              message: localizations.usernamesDoNotMatch,
              icon: const Icon(Icons.error_outline_rounded,
                  color: PassyTheme.darkContentColor));
          return;
        }
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, SplashScreen.routeName);
        data.removeAccount(_username).then((value) {
          if (data.noAccounts) {
            Navigator.pushReplacementNamed(context, AddAccountScreen.routeName);
            return;
          }
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        });
      },
    );
  }
}
