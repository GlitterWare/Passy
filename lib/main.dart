import 'package:flutter/material.dart';
import 'package:passy/screens/login.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/state.dart';
import 'common/theme.dart';
import 'screens/add_account.dart';

void main() {
  Future(() async => preferences = await SharedPreferences.getInstance())
      .whenComplete(() {
    preferences.setString('version', '0.0.0');
    if (!preferences.containsKey('accounts')) {
      preferences.setStringList('accounts', []);
      preferences.setStringList('passwords', []);
    }
    List<String> _passwords = preferences.getStringList('passwords')!;
    for (String p in _passwords) {
      List<String> _pair = p.split(' ');
      passwords[_pair[0]] = _pair[1];
    }
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
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
