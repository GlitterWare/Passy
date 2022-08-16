import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/password.dart';

import 'common.dart';
import 'theme.dart';
import 'edit_password_screen.dart';
import 'main_screen.dart';
import 'search_screen.dart';

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

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditPasswordScreen.routeName);

  void _onSearchPressed() {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: (String terms) {
      final List<Password> _found = [];
      final List<String> _terms = terms.trim().toLowerCase().split(' ');
      for (Password _password in data.loadedAccount!.passwords) {
        {
          bool testPassword(Password value) => _password.key == value.key;

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
      List<Widget> _widgets = [];
      for (Password _password in _found) {
        _widgets.add(
          Padding(
            padding: entryPadding,
            child: buildPasswordWidget(
              context: context,
              password: _password,
            ),
          ),
        );
      }
      return _widgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getEntriesScreenAppBar(context,
          title: const Center(child: Text('Passwords')),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: ListView(children: _passwordWidgets),
    );
  }
}
