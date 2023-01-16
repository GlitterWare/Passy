import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/passy_search.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';

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
  final LoadedAccount _account = data.loadedAccount!;

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditPasswordScreen.routeName);

  Widget _buildPasswords(String terms) {
    List<PasswordMeta> _found = PassySearch.searchPasswords(
        passwords: _account.passwordMetadata.values, terms: terms);
    return PasswordButtonListView(
      passwords: _found,
      onPressed: (password) => Navigator.pushNamed(
          context, PasswordScreen.routeName,
          arguments: _account.getPassword(password.key)!),
      shouldSort: true,
      popupMenuItemBuilder: passwordPopupMenuBuilder,
    );
  }

  void _onSearchPressed() {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: _buildPasswords);
  }

  @override
  Widget build(BuildContext context) {
    List<PasswordMeta> _passwords = _account.passwordMetadata.values.toList();
    return Scaffold(
      appBar: EntriesScreenAppBar(
          title: const Center(child: Text('Passwords')),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: _passwords.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      const Text(
                        'No passwords',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                          child: const Icon(Icons.add_rounded),
                          onPressed: () => Navigator.pushNamed(
                              context, EditPasswordScreen.routeName)),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            )
          : PasswordButtonListView(
              passwords: _passwords.toList(),
              onPressed: (password) => Navigator.pushNamed(
                  context, PasswordScreen.routeName,
                  arguments: _account.getPassword(password.key)!),
              shouldSort: true,
              popupMenuItemBuilder: passwordPopupMenuBuilder,
            ),
    );
  }
}
