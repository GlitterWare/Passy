import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:passy_website/passy_flutter/passy_flutter.dart';
import 'package:passy_website/screens/downloads_screen.dart';
import 'screens/main_screen.dart';

void main() {
  usePathUrlStrategy();
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
        DownloadsScreen.routeName: (context) => const DownloadsScreen(),
      },
    );
  }
}
