import 'dart:io';

import 'package:flutter/material.dart';

import 'package:passy/common/state.dart';
import 'package:passy/passy/app_data.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:path_provider/path_provider.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    Future(() async {
      data = AppData((await getApplicationDocumentsDirectory()).path +
          Platform.pathSeparator +
          'Passy');
      loadApp(context);
    });
    return const SplashScreen();
  }
}
