import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/screen.dart';
import 'package:passy/screens/add_account_screen.dart';

import 'log_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  String _password = '';
  String _username = data.info.value.lastUsername;

  List<DropdownMenuItem<String>> usernames = data.usernames
      .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
            child: Text(e),
            value: e,
          ))
      .toList();

  void login() {
    if (getHash(_password).toString() != data.getPasswordHash(_username)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
        Icon(
          Icons.lock_rounded,
          color: darkContentColor,
        ),
        const SizedBox(width: 20),
        const Expanded(child: Text('Incorrect password')),
      ])));
      return;
    }
    data.info.value.lastUsername = _username;
    data.info.save().whenComplete(() {
      try {
        LoadedAccount _account =
            data.loadAccount(data.info.value.lastUsername, _password);
        Navigator.pushReplacementNamed(
            context, screenToRouteName[_account.defaultScreen]!);
      } catch (e, s) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Row(children: [
              Icon(Icons.lock_rounded, color: lightContentColor),
            ]),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
                  arguments: e.toString() + '\n' + s.toString()),
            ),
          ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const Spacer(flex: 2),
                purpleLogo,
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
                                FloatingActionButton(
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(
                                          context, AddAccountScreen.routeName),
                                  child: const Icon(Icons.add_rounded),
                                  heroTag: 'addAccountBtn',
                                ),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _username,
                                    items: usernames,
                                    onChanged: (a) {
                                      if (a! == 'addAccount') {
                                        Navigator.pushReplacementNamed(context,
                                            AddAccountScreen.routeName);
                                        return;
                                      }
                                      _username = a;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    obscureText: true,
                                    onChanged: (a) => _password = a,
                                    decoration: const InputDecoration(
                                      hintText: 'Password',
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(' '),
                                      LengthLimitingTextInputFormatter(32),
                                    ],
                                    autofocus: true,
                                  ),
                                ),
                                FloatingActionButton(
                                  onPressed: () => login(),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                  ),
                                  heroTag: 'loginBtn',
                                ),
                              ],
                            ),
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
        ],
      ),
    );
  }
}
