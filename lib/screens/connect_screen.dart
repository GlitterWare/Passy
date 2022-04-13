import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';

import 'main_screen.dart';

class ConnectScreen extends StatelessWidget {
  static const routeName = '/connect';

  const ConnectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? _backButton = getBackButton(
        onPressed: () =>
            Navigator.pushReplacementNamed(context, MainScreen.routeName));
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
        title: const Center(child: Text('Connect')),
      ),
    );
  }
}
