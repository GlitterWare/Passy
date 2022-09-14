import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/passy_search.dart';
import 'package:passy/screens/remove_account_screen.dart';
import 'package:passy/screens/search_screen.dart';
import 'package:universal_io/io.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/screen.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/common/assets.dart';

import 'add_account_screen.dart';
import 'common.dart';
import 'main_screen.dart';
import 'log_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool autofillLogin;

  const LoginScreen({Key? key, this.autofillLogin = false}) : super(key: key);

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> with WidgetsBindingObserver {
  static bool didRun = false;
  String _password = '';
  String _username = data.info.value.lastUsername;

  Future<void> _onResumed() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (data.getBioAuthEnabled(_username) ?? false) {
        if (await bioAuth(_username)) {
          Navigator.pushReplacementNamed(context, MainScreen.routeName);
          LoadedAccount _account = data.loadedAccount!;
          if (_account.defaultScreen != Screen.main) {
            Navigator.pushNamed(
                context, screenToRouteName[_account.defaultScreen]!);
          }
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) _onResumed();
  }

  Widget _buildPasswords(String terms) {
    List<Password> _found = PassySearch.searchPasswords(
        passwords: data.loadedAccount!.passwords, terms: terms);
    List<PwDataset> _dataSets = [];
    for (Password _password in _found) {
      _dataSets.add(PwDataset(
        label: _password.nickname,
        username: _password.username,
        password: _password.password,
      ));
    }
    return PasswordButtonListView(
      passwords: _found,
      onPressed: (password) async {
        await AutofillService().resultWithDatasets(_dataSets);
        Navigator.pop(context);
      },
      shouldSort: true,
    );
  }

  void login() {
    if (getPassyHash(_password).toString() != data.getPasswordHash(_username)) {
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
    data.info.value.lastUsername = _username;
    data.info.save().whenComplete(() async {
      try {
        LoadedAccount _account = data.loadAccount(
            data.info.value.lastUsername, getPassyEncrypter(_password));
        if (widget.autofillLogin) {
          Navigator.pushNamed(
            context,
            SearchScreen.routeName,
            arguments: _buildPasswords,
          );
          return;
        }
        Navigator.pushReplacementNamed(context, MainScreen.routeName);
        if (_account.defaultScreen == Screen.main) return;
        Navigator.pushNamed(
            context, screenToRouteName[_account.defaultScreen]!);
      } catch (e, s) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Row(children: const [
              Icon(Icons.lock_rounded, color: PassyTheme.darkContentColor),
              SizedBox(width: 20),
              Text('Could not login'),
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (didRun) return;
    didRun = true;
    _onResumed();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String>> usernames = data.usernames
        .map<DropdownMenuItem<String>>((_username) => DropdownMenuItem(
              child: Row(children: [
                Expanded(child: Text(_username)),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      RemoveAccountScreen.routeName,
                      arguments: _username,
                    );
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  splashRadius: PassyTheme.appBarButtonSplashRadius,
                  padding: PassyTheme.appBarButtonPadding,
                ),
              ]),
              value: _username,
            ))
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
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
                                    selectedItemBuilder: (context) {
                                      return usernames.map<Widget>((item) {
                                        return Text(item.value!);
                                      }).toList();
                                    },
                                    onChanged: (a) {
                                      setState(() => _username = a!);
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
                                    onChanged: (a) =>
                                        setState(() => _password = a),
                                    decoration: const InputDecoration(
                                      hintText: 'Password',
                                    ),
                                    inputFormatters: [
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
