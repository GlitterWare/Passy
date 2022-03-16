import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'common/state.dart';
import 'common/theme.dart';
import 'passy/passy_data.dart';
import 'screens/add_account.dart';
import 'screens/empty.dart';
import 'screens/login.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';

const String version = '0.0.0';

void main() {
  Future(() async => data = AppData(
      (await getApplicationDocumentsDirectory()).path +
          Platform.pathSeparator +
          'Passy')).whenComplete(() => loaded.complete());
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
        '/': (context) => const StartScreen(),
        '/splash': (context) => const SplashScreen(),
        '/addAccount': (context) => const AddAccount(),
        '/login': (context) => const Login(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
