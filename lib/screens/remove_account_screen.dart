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
  late FormattedTextParser formattedTextParser;

  @override
  void initState() {
    super.initState();
    formattedTextParser = FormattedTextParser(context: context);
  }

  @override
  Widget build(BuildContext context) {
    String _username = ModalRoute.of(context)!.settings.arguments as String;
    return ConfirmStringScaffold(
      title: Text(localizations.removeAccount),
      message: PassyPadding(Text.rich(
        formattedTextParser.parse(
          text:
              '${localizations.confirmRemoveAccountMsg}\n\n${localizations.thisActionIsIrreversible}',
          placeholders: {
            'u': TextSpan(
              text: '\'$_username\'',
              style: TextStyle(
                  color: PassyTheme.of(context).highlightContentSecondaryColor),
            ),
          },
        ),
        textAlign: TextAlign.center,
      )),
      labelText: localizations.confirmUsername,
      confirmIcon: const Icon(Icons.delete_outline_rounded),
      onBackPressed: (context) => Navigator.pop(context),
      onConfirmPressed: (context, value) {
        if (value != _username) {
          showSnackBar(
            message: localizations.usernamesDoNotMatch,
            icon: const Icon(Icons.error_outline_rounded),
          );
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
