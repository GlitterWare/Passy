import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:passy/common/state.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddAccount();
}

class _AddAccount extends State<StatefulWidget> {
  String _username = '';
  String _password = '';
  String _confirmPassword = '';
  final String _icon = 'assets/images/logo_circle.cvg';
  final Color _iconColor = Colors.purple;

  void addAccount() {
    if (accounts.containsKey(_username)) {
      throw Exception('Cannot have two accounts with the same login');
    }
    if (accounts.isEmpty) preferences.setString('lastLogin', _username);

    List<String> _accountData = preferences.getStringList('accountData')!;
    List<String> _icons = preferences.getStringList('icons')!;
    List<String> _iconColors = preferences.getStringList('colors')!;
    List<String> _passwords = preferences.getStringList('passwords')!;
    List<String> _usernames = preferences.getStringList('usernames')!;

    String _cryptoPassword = getPasswordHash(_password);

    accounts[_username] =
        Account(_usernames.length, _cryptoPassword, _icon, _iconColor);

    _accountData.add(AccountData().encrypt(_password));
    _icons.add(_icon);
    _iconColors.add(_iconColor.value.toString());
    _passwords.add(_cryptoPassword);
    _usernames.add(_username);

    preferences.setStringList('accountData', _accountData);
    preferences.setStringList('icons', _icons);
    preferences.setStringList('colors', _iconColors);
    preferences.setStringList('passwords', _passwords);
    preferences.setStringList('usernames', _usernames);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Expanded(
            child: purpleLogo,
            flex: 3,
          ),
          const Spacer(),
          const Expanded(
            child: Text(
              'Add an account',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            flex: 2,
          ),
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
                              onChanged: (a) => _username = a,
                              decoration: InputDecoration(
                                border: outlineInputBorder,
                                hintText: 'Username',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(' ')
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
                              onChanged: (a) => _password = a,
                              decoration: InputDecoration(
                                border: outlineInputBorder,
                                hintText: 'Password',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(' ')
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
                              decoration: InputDecoration(
                                border: outlineInputBorder,
                                hintText: 'Confirm password',
                              ),
                              onChanged: (a) => _confirmPassword = a,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(' ')
                              ],
                            ),
                          ),
                          FloatingActionButton(
                            onPressed: () async {
                              if (_username.isEmpty) return;
                              if (_password.isEmpty) return;
                              if (_password != _confirmPassword) return;
                              addAccount();
                              loadApp(context);
                            },
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                            ),
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
    );
  }
}
