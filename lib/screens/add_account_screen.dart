import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/screens/setup_screen.dart';

import '../common/assets.dart';
import 'login_screen.dart';
import 'log_screen.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({Key? key}) : super(key: key);

  static const routeName = '/addAccount';

  @override
  State<StatefulWidget> createState() => _AddAccountScreen();
}

class _AddAccountScreen extends State<StatefulWidget> {
  String _username = '';
  String _password = '';
  String _confirmPassword = '';

  void _addAccount() {
    if (_username.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: const [
        Icon(Icons.person_rounded, color: PassyTheme.darkContentColor),
        SizedBox(width: 20),
        Text('Username is empty'),
      ])));
      return;
    }
    if (_username.length < 2) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: const [
        Icon(Icons.person_rounded, color: PassyTheme.darkContentColor),
        SizedBox(width: 20),
        Text('Username is shorter than 2 letters'),
      ])));
      return;
    }
    if (data.hasAccount(_username)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: const [
        Icon(Icons.person_rounded, color: PassyTheme.darkContentColor),
        SizedBox(width: 20),
        Text('Username is already in use'),
      ])));
      return;
    }
    if (_password.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: const [
        Icon(Icons.lock_rounded, color: PassyTheme.darkContentColor),
        SizedBox(width: 20),
        Text('Password is empty'),
      ])));
      return;
    }
    if (_password != _confirmPassword) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: const [
        Icon(Icons.lock_rounded, color: PassyTheme.darkContentColor),
        SizedBox(width: 20),
        Text('Passwords do not match'),
      ])));
      return;
    }
    try {
      data.createAccount(
        _username,
        _password,
      );
    } catch (e, s) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Row(children: const [
            Icon(Icons.error_outline_rounded,
                color: PassyTheme.darkContentColor),
            SizedBox(width: 20),
            Expanded(child: Text('Couldn\'t add account')),
          ]),
          action: SnackBarAction(
            label: 'Details',
            onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
                arguments: e.toString() + '\n' + s.toString()),
          ),
        ));
      return;
    }
    data.info.value.lastUsername = _username;
    data.loadAccount(_username, getPassyEncrypter(_password));
    data.info.save().then((value) {
      Navigator.pushReplacementNamed(context, SetupScreen.routeName);
    });
  }

  Future<bool> _onWillPop() {
    if (data.noAccounts) return Future.value(true);
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: data.noAccounts
              ? null
              : IconButton(
                  padding: PassyTheme.appBarButtonPadding,
                  splashRadius: PassyTheme.appBarButtonSplashRadius,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, LoginScreen.routeName),
                ),
          title: const Text('Add account'),
          centerTitle: true,
        ),
        body: CustomScrollView(slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const Spacer(flex: 2),
                logo60Purple,
                const Spacer(),
                Expanded(
                  child: Row(
                    children: [
                      const Spacer(),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onChanged: (a) =>
                                        setState(() => _username = a),
                                    decoration: const InputDecoration(
                                      hintText: 'Username',
                                    ),
                                    autofocus: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter(
                                          RegExp(
                                              '^[a-zA-Z0-9](?:[a-zA-Z0-9 ._-]*[a-zA-Z0-9])?\$'),
                                          replacementString: _username,
                                          allow: true)
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    obscureText: true,
                                    onChanged: (a) =>
                                        setState(() => _password = a),
                                    decoration: const InputDecoration(
                                      hintText: 'Password',
                                    ),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(32),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      hintText: 'Confirm password',
                                    ),
                                    onChanged: (a) =>
                                        setState(() => _confirmPassword = a),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(32),
                                    ],
                                  ),
                                ),
                                FloatingActionButton(
                                  onPressed: _addAccount,
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                  ),
                                  heroTag: 'addAccountBtn',
                                ),
                              ],
                            ),
                            const Spacer(flex: 2),
                          ],
                        ),
                        flex: 10,
                      ),
                      const Spacer(),
                    ],
                  ),
                  flex: 4,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
