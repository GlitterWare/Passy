import 'package:flutter/material.dart';
import 'package:passy/widgets/back_button.dart';

class ConnectScreen extends StatelessWidget {
  static const routeName = '/connect';

  const ConnectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Connect'),
        centerTitle: true,
      ),
    );
  }
}
