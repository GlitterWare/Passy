import 'package:flutter/material.dart';

import '../common/state.dart';
import '../common/theme.dart';
import '../passy/passy.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddAccount();
}

class _AddAccount extends State<StatefulWidget> {
  String _username = '';
  String _password = '';
  String _confirmPassword = '';

  Future<void> addAccount() async {
    if (accounts.containsKey(_username)) {
      throw Exception('Cannot have two accounts with the same login');
    }
    if (accounts.isEmpty) preferences.setString('lastLogin', _username);
    accounts[_username] = Account(_password);
    //jsonEncode(accounts);
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
                            ),
                          ),
                          FloatingActionButton(
                            onPressed: () async {
                              if (_password != _confirmPassword) return;
                              await addAccount();
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
