import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';

import 'credentials_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'splash_screen.dart';

class ChangeUsernameScreen extends StatefulWidget {
  static const String routeName =
      '${CredentialsScreen.routeName}/changeUsername';

  const ChangeUsernameScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChangeUsernameScreen();
}

class _ChangeUsernameScreen extends State<StatefulWidget> {
  final LoadedAccount _account = data.loadedAccount!;

  @override
  Widget build(BuildContext context) {
    return ConfirmStringScaffold(
      onBackPressed: (context) => Navigator.pop(context),
      title: const Text('Change username'),
      labelText: 'New username',
      onConfirmPressed: (context, value) {
        if (value.length < 2) {
          showSnackBar(context,
              message: 'Username is shorter than 2 letters',
              icon: const Icon(Icons.person_rounded,
                  color: PassyTheme.darkContentColor));
          return;
        }
        if (data.hasAccount(value)) {
          showSnackBar(context,
              message: 'Username is already in use',
              icon: const Icon(Icons.person_rounded,
                  color: PassyTheme.darkContentColor));
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
                  (_) => Navigator.pushReplacementNamed(
                      context, LoginScreen.routeName),
                );
            return true;
          },
        );
      },
      message: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'Current username is ',
          children: [
            TextSpan(
              text: _account.username,
              style: const TextStyle(
                color: PassyTheme.lightContentSecondaryColor,
              ),
            ),
            const TextSpan(text: '.\nType in the new username.'),
          ],
        ),
      ),
    );
  }
}
