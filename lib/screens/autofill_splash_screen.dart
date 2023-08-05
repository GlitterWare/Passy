import 'package:flutter/material.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/common/common.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/no_accounts_screen.dart';

import 'common.dart';

class AutofillSplashScreen extends StatefulWidget {
  static const routeName = '/';

  const AutofillSplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutofillSplashScreen();
}

class _AutofillSplashScreen extends State<AutofillSplashScreen> {
  static bool initialized = false;

  @override
  void initState() {
    if (initialized) return;
    initialized = true;
    super.initState();
    loadPassyData().then((value) async {
      data = value;
      loadLocalizations(context);
      if (value.noAccounts) {
        Navigator.pushReplacementNamed(context, NoAccountsScreen.routeName);
        return;
      }
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    setOnError(context);
    return Scaffold(
      body: Center(
        child: logo60Purple,
      ),
    );
  }
}
