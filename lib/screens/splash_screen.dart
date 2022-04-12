import 'package:flutter/material.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/passy_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static const routeName = '/';
  static bool loaded = false;

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      Future(() async {
        data = PassyData((await getApplicationDocumentsDirectory()).path +
            Platform.pathSeparator +
            'Passy');
        data.noAccounts
            ? Navigator.pushNamed(context, '/addAccount')
            : Navigator.pushNamed(context, '/login');
      });
      loaded = true;
    }
    return Scaffold(
      body: Center(
        child: purpleLogo,
      ),
    );
  }
}
