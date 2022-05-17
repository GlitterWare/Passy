import 'package:flutter/material.dart';
import 'package:passy/widgets/back_button.dart';

class RemoveAccountScreen extends StatefulWidget {
  const RemoveAccountScreen({Key? key}) : super(key: key);

  static const routeName = '/login/removeAccount';

  @override
  State<StatefulWidget> createState() => _RemoveAccountScreen();
}

class _RemoveAccountScreen extends State<RemoveAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Remove account'),
        centerTitle: true,
      ),
    );
  }
}
