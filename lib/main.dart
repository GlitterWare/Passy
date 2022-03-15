import 'package:flutter/material.dart';
import 'package:passy/screens/empty.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:passy/common/state.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/screens/add_account.dart';
import 'package:passy/screens/login.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/splash_screen.dart';

void main() {
  Future(() async => preferences = await SharedPreferences.getInstance())
      .whenComplete(() {
    if (!preferences.containsKey('version')) {
      preferences.setStringList('accountData', []);
      preferences.setStringList('icons', []);
      preferences.setStringList('iconColors', []);
      preferences.setStringList('passwords', []);
      preferences.setStringList('usernames', []);
      preferences.setString('version', '0.0.0');
    }
    List<String> _icons = preferences.getStringList('icons')!;
    List<String> _iconColors = preferences.getStringList('iconColors')!;
    List<String> _usernames = preferences.getStringList('usernames')!;
    List<String> _passwords = preferences.getStringList('passwords')!;
    for (int i = 0; i != _usernames.length; i++) {
      accounts[_usernames[i]] = Account(
          i, _passwords[i], _icons[i], Color(int.parse(_iconColors[i])));
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
        '/': (context) => const Empty(),
        '/splash': (context) => const SplashScreen(),
        '/addAccount': (context) => const AddAccount(),
        '/login': (context) => const Login(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
