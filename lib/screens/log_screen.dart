import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({Key? key}) : super(key: key);

  static const routeName = '/log';

  @override
  Widget build(BuildContext context) {
    final String _log = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Log'),
          centerTitle: true,
          leading: getBackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SelectableText(_log));
  }
}
