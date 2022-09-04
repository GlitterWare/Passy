import 'package:flutter/material.dart';
import 'package:passy/passy_data/biometric_storage_data.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/passy_data.dart';
import 'package:passy/common/assets.dart';

import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static const routeName = '/';
  static bool loaded = false;

  @override
  Widget build(BuildContext context) {
    Future<void> _load() async {
      data = PassyData((await getApplicationDocumentsDirectory()).path +
          Platform.pathSeparator +
          'Passy');
      loaded = true;
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }

    if (!loaded) {
      _load();
    }
    return Scaffold(
      body: Center(
        child: logo60Purple,
      ),
    );
  }
}
