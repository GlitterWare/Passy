import 'package:flutter/material.dart';
import 'package:passy/screens/login.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/state.dart';
import 'common/theme.dart';
import 'screens/add_account.dart';

void main() {
  Future(() async => preferences = await SharedPreferences.getInstance())
      .whenComplete(() {
    preferences.setString('version', '0.0.0');
    loaded.complete();
  });
  runApp(const Passy());
}

class Passy extends StatelessWidget {
  const Passy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passy',
      theme: theme,
      routes: {
        '/': (context) => const SplashScreen(),
        '/addAccount': (context) => const AddAccount(),
        '/login': (context) => const Login(),
        '/signIn': (context) => const Login(),
      },
    );
  }
}
