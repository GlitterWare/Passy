import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';

import 'security_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'splash_screen.dart';

class ChangeUsernameScreen extends StatefulWidget {
  static const String routeName = '${SecurityScreen.routeName}/changeUsername';

  const ChangeUsernameScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChangeUsernameScreen();
}

class _ChangeUsernameScreen extends State<StatefulWidget> {
  final LoadedAccount _account = data.loadedAccount!;
  late FormattedTextParser formattedTextParser;

  @override
  void initState() {
    super.initState();
    formattedTextParser = FormattedTextParser(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmStringScaffold(
      onBackPressed: (context) => Navigator.pop(context),
      title: Text(localizations.changeUsername),
      labelText: localizations.newUsername,
      onConfirmPressed: (context, value) {
        if (value.length < 2) {
          showSnackBar(
            message: localizations.usernameShorterThan2Letters,
            icon: const Icon(Icons.person_rounded),
          );
          return;
        }
        if (data.hasAccount(value)) {
          showSnackBar(
            message: localizations.usernameAlreadyInUse,
            icon: const Icon(Icons.person_rounded),
          );
          return;
        }
        Navigator.popUntil(
          context,
          (route) {
            if (route.settings.name != MainScreen.routeName) {
              return false;
            }
            Navigator.pushReplacementNamed(context, SplashScreen.routeName);
            data.changeAccountUsername(_account.username, value).then(
              (_) async {
                _account.bioAuthEnabled = false;
                await _account.saveCredentials();
                if (mounted) {
                  return Navigator.pushReplacementNamed(
                      context, LoginScreen.routeName);
                }
              },
            );
            return true;
          },
        );
      },
      message: Text.rich(
        formattedTextParser.parse(
          text: localizations.currentUsernameIs,
          placeholders: {
            'u': TextSpan(
              text: _account.username,
              style: TextStyle(
                color: PassyTheme.of(context).highlightContentSecondaryColor,
              ),
            ),
          },
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
