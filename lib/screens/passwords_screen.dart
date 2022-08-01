import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/search_screen.dart';
import 'package:passy/widgets/passy_back_button.dart';

import 'edit_password_screen.dart';

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/passwords';

  @override
  State<StatefulWidget> createState() => _PasswordsScreen();
}

class _PasswordsScreen extends State<PasswordsScreen> {
  final List<Widget> _passwordWidgets = [];

  @override
  void initState() {
    super.initState();
    List<Widget> _widgets =
        buildPasswordWidgets(context: context, account: data.loadedAccount!);
    _passwordWidgets.addAll(_widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(onPressed: () => Navigator.pop(context)),
        title: const Center(child: Text('Passwords')),
        actions: [
          IconButton(
            padding: appBarButtonPadding,
            splashRadius: appBarButtonSplashRadius,
            onPressed: () => Navigator.pushNamed(
              context,
              SearchScreen.routeName,
              arguments: (String terms, List<Widget> widgets) {
                final List<Password> _found = [];
                final List<String> _terms =
                    terms.trim().toLowerCase().split(' ');
                print(_terms);
                for (Password _password in data.loadedAccount!.passwords) {
                  {
                    bool testPassword(Password value) =>
                        _password.key == value.key;

                    if (_found.any(testPassword)) continue;
                  }
                  {
                    int _positiveCount = 0;
                    for (String _term in _terms) {
                      if (_password.username.toLowerCase().contains(_term)) {
                        _positiveCount++;
                        continue;
                      }
                      if (_password.nickname.toLowerCase().contains(_term)) {
                        _positiveCount++;
                        continue;
                      }
                    }
                    if (_positiveCount == _terms.length) {
                      _found.add(_password);
                    }
                  }
                }
                sortPasswords(_found);
                widgets.clear();
                for (Password _password in _found) {
                  widgets.add(buildPasswordWidget(
                      context: context, password: _password));
                }
              },
            ),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            padding: appBarButtonPadding,
            splashRadius: appBarButtonSplashRadius,
            onPressed: () =>
                Navigator.pushNamed(context, EditPasswordScreen.routeName),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(children: _passwordWidgets),
    );
  }
}
