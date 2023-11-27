import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/setup_screen.dart';
import 'package:encrypt/encrypt.dart' as crypt;

import '../common/assets.dart';
import 'log_screen.dart';
import 'login_screen.dart';

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

  void _addAccount() async {
    if (_username.isEmpty) {
      showSnackBar(
        context,
        message: localizations.usernameIsEmpty,
        icon: const Icon(Icons.person_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    if (_username.length < 2) {
      showSnackBar(
        context,
        message: localizations.usernameShorterThan2Letters,
        icon: const Icon(Icons.person_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    if (data.hasAccount(_username)) {
      showSnackBar(
        context,
        message: localizations.usernameAlreadyInUse,
        icon: const Icon(Icons.person_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    if (_password.isEmpty) {
      showSnackBar(
        context,
        message: localizations.passwordIsEmpty,
        icon:
            const Icon(Icons.lock_rounded, color: PassyTheme.darkContentColor),
      );
      return;
    }
    if (_password != _confirmPassword) {
      showSnackBar(
        context,
        message: localizations.passwordsDoNotMatch,
        icon:
            const Icon(Icons.lock_rounded, color: PassyTheme.darkContentColor),
      );
      return;
    }
    try {
      await data.createAccount(
        _username,
        _password,
      );
    } catch (e, s) {
      if (!mounted) return;
      showSnackBar(
        context,
        message: localizations.couldNotAddAccount,
        icon: const Icon(Icons.error_outline_rounded,
            color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
      return;
    }
    data.info.value.lastUsername = _username;
    crypt.Key key =
        (await data.derivePassword(_username, password: _password))!;
    LoadedAccount account = await data.loadAccount(
        _username, getPassyEncrypterFromBytes(key.bytes), key);
    account.startAutoSync(key.base64);
    data.info.save().then((value) {
      if (!mounted) return;
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
          title: Text(localizations.createLocalAccount),
          centerTitle: true,
        ),
        body: CustomScrollView(slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const Spacer(flex: 5),
                logo60Purple,
                const Spacer(),
                Text.rich(
                  TextSpan(
                    text: localizations.yourAccountWillBeStoredLocally1,
                    children: [
                      TextSpan(
                          text: localizations
                              .yourAccountWillBeStoredLocally2Highlighted,
                          style: const TextStyle(
                              color: PassyTheme.lightContentSecondaryColor)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
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
                                    decoration: InputDecoration(
                                      hintText: localizations.username,
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
                                    decoration: InputDecoration(
                                      hintText: localizations.password,
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
                                    decoration: InputDecoration(
                                      hintText: localizations.confirmPassword,
                                    ),
                                    onChanged: (a) =>
                                        setState(() => _confirmPassword = a),
                                    onSubmitted: (value) => _addAccount(),
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
                                  tooltip: localizations.addAccount,
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
                  flex: 10,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
