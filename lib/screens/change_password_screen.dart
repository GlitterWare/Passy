import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
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
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: const [
        Icon(
          Icons.lock_rounded,
          color: PassyTheme.darkContentColor,
        ),
        SizedBox(width: 20),
        Expanded(child: Text('Incorrect password')),
      ])));
      return;
    }
    if (_newPassword.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: const [
        Icon(Icons.lock_rounded, color: PassyTheme.darkContentColor),
        SizedBox(width: 20),
        Text('Password is empty'),
      ])));
      return;
    }
    if (_newPassword != _newPasswordConfirm) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: const [
        Icon(Icons.lock_rounded, color: PassyTheme.darkContentColor),
        SizedBox(width: 20),
        Text('Passwords do not match'),
      ])));
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
        title: const Text('Change password'),
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
                text:
                    TextSpan(text: 'You\'re changing password for ', children: [
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
                        decoration: const InputDecoration(
                            labelText: 'Current password'),
                        obscureText: true,
                        onChanged: (s) => setState(() => _password = s),
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'New password'),
                        obscureText: true,
                        onChanged: (s) => setState(() => _newPassword = s),
                      ),
                      ButtonedTextFormField(
                        labelText: 'Confirm password',
                        obscureText: true,
                        onChanged: (s) =>
                            setState(() => _newPasswordConfirm = s),
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
