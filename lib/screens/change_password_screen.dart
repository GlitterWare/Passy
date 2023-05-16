import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/credentials_screen.dart';
import 'package:passy/screens/splash_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String routeName =
      '${CredentialsScreen.routeName}/changePassword';

  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChangePasswordScreen();
}

class _ChangePasswordScreen extends State<ChangePasswordScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  String _password = '';
  String _newPassword = '';
  String _newPasswordConfirm = '';

  void _onConfirmPressed() {
    if (getPassyHash(_password).toString() !=
        data.getPasswordHash(_account.username)) {
      showSnackBar(context,
          message: localizations.incorrectPassword,
          icon: const Icon(
            Icons.lock_rounded,
            color: PassyTheme.darkContentColor,
          ));
      return;
    }
    if (_newPassword.isEmpty) {
      showSnackBar(context,
          message: localizations.passwordIsEmpty,
          icon: const Icon(
            Icons.lock_rounded,
            color: PassyTheme.darkContentColor,
          ));
      return;
    }
    if (_newPassword != _newPasswordConfirm) {
      showSnackBar(context,
          message: localizations.passwordsDoNotMatch,
          icon: const Icon(
            Icons.lock_rounded,
            color: PassyTheme.darkContentColor,
          ));
      return;
    }
    Navigator.pushNamed(context, SplashScreen.routeName);
    _account.setAccountPassword(_newPassword);
    _account.save().then((value) {
      Navigator.popUntil(context,
          (route) => route.settings.name == CredentialsScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.changePassword),
        centerTitle: true,
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(children: [
              const Spacer(),
              RichText(
                text: TextSpan(
                    text: localizations.youAreChangingPasswordFor,
                    children: [
                      TextSpan(
                        text: _account.username,
                        style: const TextStyle(
                          color: PassyTheme.lightContentSecondaryColor,
                        ),
                      ),
                      const TextSpan(text: '.')
                    ]),
              ),
              Expanded(
                child: PassyPadding(
                  Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: localizations.currentPassword),
                        obscureText: true,
                        onChanged: (s) => setState(() => _password = s),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: localizations.newPassword),
                        obscureText: true,
                        onChanged: (s) => setState(() => _newPassword = s),
                      ),
                      ButtonedTextFormField(
                        labelText: localizations.confirmPassword,
                        obscureText: true,
                        onChanged: (s) =>
                            setState(() => _newPasswordConfirm = s),
                        onFieldSubmitted: (s) => _onConfirmPressed(),
                        onPressed: _onConfirmPressed,
                        buttonIcon: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ]),
          ),
        ],
      ),
    );
  }
}
