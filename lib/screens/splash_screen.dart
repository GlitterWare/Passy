import 'package:flutter/material.dart';
import 'package:passy/common/assets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static const routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: purpleLogo,
      ),
    );
  }
}
