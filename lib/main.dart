import 'package:flutter/material.dart';
import 'package:passy_website/passy_flutter/passy_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'screens/main_screen.dart';

void main() {
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:
          'Passy - Offline password manager with cross-platform synchronization',
      theme: PassyTheme.theme,
      routes: {
        MainScreen.routeName: (context) => const MainScreen(),
      },
    );
  }
}
