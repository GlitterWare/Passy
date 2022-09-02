import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

import 'edit_password_screen.dart';
import 'main_screen.dart';
import 'password_screen.dart';
import 'search_screen.dart';

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/passwords';

  @override
  State<StatefulWidget> createState() => _PasswordsScreen();
}

class _PasswordsScreen extends State<PasswordsScreen> {
  final LoadedAccount _loadedAccount = data.loadedAccount!;

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
      return PasswordButtonListView(
        passwords: _found,
        onPressed: (password) => Navigator.pushNamed(
            context, PasswordScreen.routeName,
            arguments: password),
        shouldSort: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EntriesScreenAppBar(
          title: const Center(child: Text('Passwords')),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: PasswordButtonListView(
        passwords: _loadedAccount.passwords.toList(),
        shouldSort: true,
      ),
    );
  }
}
