import 'package:flutter/material.dart';

import '../common/state.dart';
import '../common/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future(() async {
      await loaded.future;
      loadApp(context);
    });
    return Center(
      child: purpleLogo,
    );
  }
}
