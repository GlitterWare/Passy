import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/settings_screen.dart';
import 'package:passy/screens/splash_screen.dart';

class CredentialsScreen extends StatefulWidget {
  static const String routeName = '${SettingsScreen.routeName}/credentials';

  const CredentialsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CredentialsScreen();
}

class _CredentialsScreen extends State<CredentialsScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Credentials'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: const Text('Change username'),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.save_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => Navigator.pushNamed(
              context,
              ConfirmStringScreen.routeName,
              arguments: ConfirmStringScreenArguments(
                onBackPressed: (context) => Navigator.pop(context),
                title: const Text('Change username'),
                labelText: 'New username',
                onConfirmPressed: (context, value) {
                  if (value.length < 2) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Row(children: const [
                      Icon(Icons.person_rounded,
                          color: PassyTheme.darkContentColor),
                      SizedBox(width: 20),
                      Text('Username is shorter than 2 letters'),
                    ])));
                    return;
                  }
                  if (data.hasAccount(value)) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Row(children: const [
                      Icon(Icons.person_rounded,
                          color: PassyTheme.darkContentColor),
                      SizedBox(width: 20),
                      Text('Username is already in use'),
                    ])));
                    return;
                  }
                  Navigator.popUntil(
                    context,
                    (route) {
                      if (route.settings.name != MainScreen.routeName) {
                        return false;
                      }
                      Navigator.pushReplacementNamed(
                          context, SplashScreen.routeName);
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
                      const TextSpan(text: '.\nType in the new username.')
                    ],
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
