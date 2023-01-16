import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:flutter_secure_screen/flutter_secure_screen.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/passy_search.dart';
import 'package:passy/screens/remove_account_screen.dart';
import 'package:passy/screens/search_screen.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/common/assets.dart';

import 'add_account_screen.dart';
import 'common.dart';
import 'global_settings_screen.dart';
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
  Widget? _floatingActionButton;
  String _password = '';
  String _username = data.info.value.lastUsername;
  FloatingActionButton? _bioAuthButton;

  Future<void> _bioAuth() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (data.getBioAuthEnabled(_username) ?? false) {
        if (await bioAuth(_username)) {
          Navigator.popUntil(
              context, (route) => route.settings.name == LoginScreen.routeName);
          Navigator.pushReplacementNamed(context, MainScreen.routeName);
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) _bioAuth();
  }

  Widget _buildPasswords(String terms) {
    List<PasswordMeta> _found = PassySearch.searchPasswords(
        passwords: data.loadedAccount!.passwordMetadata.values, terms: terms);
    List<PwDataset> _dataSets = [];
    return PasswordButtonListView(
      passwords: _found,
      onPressed: (password) async {
        _found.remove(password);
        _found.insert(0, password);
        for (PasswordMeta _password in _found) {
          _dataSets.add(PwDataset(
            label: _password.nickname,
            username: _password.username,
            password: data.loadedAccount!.getPassword(_password.key)!.password,
          ));
        }
        await AutofillService().resultWithDatasets(_dataSets);
        Navigator.pop(context);
      },
      shouldSort: true,
    );
  }

  void login() {
    if (getPassyHash(_password).toString() != data.getPasswordHash(_username)) {
      showSnackBar(
        context,
        message: 'Incorrect password',
        icon:
            const Icon(Icons.lock_rounded, color: PassyTheme.darkContentColor),
      );
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
        if (Platform.isAndroid) {
          FlutterSecureScreen.singleton
              .setAndroidScreenSecure(_account.protectScreen);
        }
        Navigator.pushReplacementNamed(context, MainScreen.routeName);
      } catch (e, s) {
        showSnackBar(
          context,
          message: 'Could not login',
          icon: const Icon(Icons.lock_rounded,
              color: PassyTheme.darkContentColor),
          action: SnackBarAction(
            label: 'Details',
            onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
                arguments: e.toString() + '\n' + s.toString()),
          ),
        );
      }
    });
  }

  void updateBioAuthButton() {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (widget.autofillLogin) return;
    if (data.getBioAuthEnabled(_username) == true) {
      _bioAuthButton = FloatingActionButton(
        onPressed: () => _bioAuth(),
        child: const Icon(
          Icons.fingerprint_rounded,
        ),
        heroTag: null,
      );
      return;
    }
    _bioAuthButton = null;
  }

  @override
  void initState() {
    super.initState();
    if (!widget.autofillLogin) {
      FlutterSecureScreen.singleton.setAndroidScreenSecure(true);
      _floatingActionButton = FloatingActionButton(
        child: const Icon(Icons.settings_rounded),
        heroTag: null,
        onPressed: () =>
            Navigator.pushNamed(context, GlobalSettingsScreen.routeName),
      );
    }
    WidgetsBinding.instance.addObserver(this);
    if (didRun) return;
    didRun = true;
    _bioAuth();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    updateBioAuthButton();
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
      floatingActionButton: _floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30)),
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
                                  heroTag: null,
                                ),
                                if (_bioAuthButton != null) _bioAuthButton!,
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
