import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:universal_io/io.dart';

import 'common.dart';

class UnlockScreen extends StatefulWidget {
  static const String routeName = '/unlock';

  const UnlockScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UnlockScreen();
}

class _UnlockScreen extends State<UnlockScreen> with WidgetsBindingObserver {
  final LoadedAccount _account = data.loadedAccount!;
  bool _shouldPop = false;
  String _password = '';

  void _logOut() {
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

  void _unlock() {
    if (getPassyHash(_password).toString() ==
        data.getPasswordHash(_account.username)) {
      _shouldPop = true;
      Navigator.pop(context);
      return;
    }
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;
    if (Platform.isAndroid || Platform.isIOS) {
      if (_account.bioAuthEnabled) {
        if (await bioAuth(_account.username)) {
          _shouldPop = true;
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unlock'),
          centerTitle: true,
          leading: IconButton(
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            padding: PassyTheme.appBarButtonPadding,
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: _logOut,
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Column(
                children: [
                  const Spacer(),
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          obscureText: true,
                          onChanged: (a) => setState(() => _password = a),
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
                        onPressed: () => _unlock(),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                        ),
                        heroTag: 'loginBtn',
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
