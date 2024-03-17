import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/main.dart';
import 'package:passy/passy_data/bio_starge.dart';
import 'package:passy/passy_data/biometric_storage_data.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/main_screen.dart';

import 'common.dart';

class UnlockScreen extends StatefulWidget {
  static const String routeName = '/unlock';

  static bool isAuthenticating = false;

  const UnlockScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UnlockScreen();
}

class _UnlockScreen extends State<UnlockScreen> with WidgetsBindingObserver {
  bool _shouldPop = false;
  String _password = '';
  FloatingActionButton? _bioAuthButton;
  final TextEditingController _passwordController = TextEditingController();
  bool _unlockScreenOn = false;
  final FocusNode _passwordFocus = FocusNode();

  void _logOut() {
    Navigator.popUntil(navigatorKey.currentContext!,
        (route) => route.settings.name == MainScreen.routeName);
    Navigator.pushReplacementNamed(
        navigatorKey.currentContext!, LoginScreen.routeName);
    data.unloadAccount();
    setState(() {});
  }

  void _onWillPop(bool isPopped) {
    if (isPopped) return;
    if (_shouldPop) {
      setState(() => _unlockScreenOn = false);
      return;
    }
    _logOut();
  }

  Future<void> _bioAuth() async {
    LoadedAccount? account = data.loadedAccount;
    if (account == null) return;
    if (UnlockScreen.isAuthenticating) return;
    if (!mounted) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (!account.bioAuthEnabled) return;
    UnlockScreen.isAuthenticating = true;
    try {
      BiometricStorageData data = await BioStorage.fromLocker(account.username);
      Future.delayed(const Duration(seconds: 2))
          .then((value) => UnlockScreen.isAuthenticating = false);
      if (data.password.isEmpty) return;
    } catch (e) {
      Future.delayed(const Duration(seconds: 2))
          .then((value) => UnlockScreen.isAuthenticating = false);
      return;
    }
    _shouldPop = true;
    setState(() => _unlockScreenOn = false);
  }

  void _unlock() async {
    LoadedAccount? account = data.loadedAccount;
    if (account == null) return;
    String _passwordHash =
        (await data.createPasswordHash(account.username, password: _password))
            .toString();
    if (_passwordHash == data.getPasswordHash(account.username)) {
      _shouldPop = true;
      setState(() {
        _password = '';
        _passwordController.text = '';
        _unlockScreenOn = false;
      });
      return;
    }
    showSnackBar(
        message: localizations.incorrectPassword,
        icon: const Icon(
          Icons.lock_rounded,
          color: PassyTheme.darkContentColor,
        ));
    setState(() {
      _password = '';
      _passwordController.text = '';
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    _passwordFocus.addListener(() {
      if (!_unlockScreenOn) return;
      if (!_passwordFocus.hasFocus) _passwordFocus.requestFocus();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    _passwordFocus.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (_unlockScreenOn) return;
    if (!MainScreen.shouldLockScreen) return;
    LoadedAccount? account = data.loadedAccount;
    if (account == null) return;
    if (!account.autoScreenLock) return;
    if (UnlockScreen.isAuthenticating) return;
    if ((state != AppLifecycleState.resumed) &&
        (state != AppLifecycleState.inactive)) return;
    setState(() => _unlockScreenOn = true);
    _passwordFocus.requestFocus();
    await _bioAuth();
  }

  @override
  Widget build(BuildContext context) {
    LoadedAccount? account = data.loadedAccount;
    if (account == null) {
      _unlockScreenOn = false;
      return const SizedBox.shrink();
    }
    if (!_unlockScreenOn) return const SizedBox.shrink();
    if (Platform.isAndroid && !Platform.isIOS) {
      if (data.getBioAuthEnabled(account.username) == true) {
        _bioAuthButton = FloatingActionButton(
          onPressed: () {
            UnlockScreen.isAuthenticating = false;
            _bioAuth();
          },
          child: const Icon(
            Icons.fingerprint_rounded,
          ),
          tooltip: localizations.authenticate,
          heroTag: null,
        );
      } else {
        _bioAuthButton = null;
      }
    }
    return PopScope(
      canPop: false,
      onPopInvoked: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.unlock),
          centerTitle: true,
          leading: IconButton(
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            padding: PassyTheme.appBarButtonPadding,
            icon: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: const Icon(Icons.exit_to_app_rounded),
            ),
            onPressed: _logOut,
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const Spacer(
                    flex: 5,
                  ),
                  Text(
                    account.username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  PassyPadding(
                    ButtonedTextFormField(
                      focusNode: _passwordFocus,
                      controller: _passwordController,
                      labelText: localizations.password,
                      obscureText: true,
                      onChanged: (a) => setState(() => _password = a),
                      onFieldSubmitted: (value) => _unlock(),
                      onPressed: _unlock,
                      buttonIcon: const Icon(Icons.arrow_forward_ios_rounded),
                      autofocus: true,
                    ),
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                  if (_bioAuthButton != null) _bioAuthButton!,
                  const Spacer(
                    flex: 3,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
