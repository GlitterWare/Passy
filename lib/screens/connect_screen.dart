import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';

class ConnectScreen extends StatelessWidget {
  static const routeName = '/connect';

  const ConnectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? _backButton = getBackButton(context);
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
        title: const Center(child: Text('Connect')),
      ),
    );
  }
}
