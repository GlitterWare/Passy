import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/change_password_screen.dart';
import 'package:passy/screens/change_username_screen.dart';
import 'package:passy/screens/settings_screen.dart';

class CredentialsScreen extends StatefulWidget {
  static const String routeName = '${SettingsScreen.routeName}/credentials';

  const CredentialsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CredentialsScreen();
}

class _CredentialsScreen extends State<CredentialsScreen> {
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
        title: Text(localizations.credentials),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.changeUsername),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.person_outline_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, ChangeUsernameScreen.routeName),
          )),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.changePassword),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.lock_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, ChangePasswordScreen.routeName),
          )),
        ],
      ),
    );
  }
}
