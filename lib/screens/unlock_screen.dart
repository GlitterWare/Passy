import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
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
  final LoadedAccount _account = data.loadedAccount!;
  bool _shouldPop = false;
  String _password = '';
  FloatingActionButton? _bioAuthButton;
  final TextEditingController _passwordController = TextEditingController();

  void _logOut() {
    Navigator.popUntil(
        context, (route) => route.settings.name == MainScreen.routeName);
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    data.unloadAccount();
  }

  Future<bool> _onWillPop() {
    if (_shouldPop) return Future.value(true);
    Navigator.popUntil(context, (route) {
      if (route.settings.name != MainScreen.routeName) return false;
      _logOut();
      return true;
    });
    return Future.value(false);
  }

  Future<void> _bioAuth() async {
    if (UnlockScreen.isAuthenticating) return;
    if (!mounted) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (!_account.bioAuthEnabled) return;
    UnlockScreen.isAuthenticating = true;
    try {
      BiometricStorageData data =
          await BioStorage.fromLocker(_account.username);
      Future.delayed(const Duration(seconds: 2))
          .then((value) => UnlockScreen.isAuthenticating = false);
      if (data.password.isEmpty) return;
    } catch (e) {
      Future.delayed(const Duration(seconds: 2))
          .then((value) => UnlockScreen.isAuthenticating = false);
      return;
    }
    _shouldPop = true;
    Navigator.pop(context);
  }

  void _unlock() async {
    String _passwordHash =
        (await data.createPasswordHash(_account.username, password: _password))
            .toString();
    _password = '';
    if (_passwordHash == data.getPasswordHash(_account.username)) {
      _shouldPop = true;
      Navigator.pop(context);
      return;
    }
    showSnackBar(context,
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
    WidgetsBinding.instance.addObserver(this);
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (data.getBioAuthEnabled(_account.username) == true) {
      _bioAuthButton = FloatingActionButton(
        onPressed: () => _bioAuth(),
        child: const Icon(
          Icons.fingerprint_rounded,
        ),
        tooltip: localizations.authenticate,
        heroTag: null,
      );
      return;
    }
    _bioAuthButton = null;
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;
    await _bioAuth();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
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
                    _account.username,
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
