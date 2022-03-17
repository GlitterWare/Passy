import 'package:flutter/material.dart';

import 'package:passy/common/state.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    Future(() async {
      await loaded.future;
      loadApp(context);
    });
    return const Scaffold();
  }
}
