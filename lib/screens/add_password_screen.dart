import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy/password.dart';

class AddPasswordScreen extends StatefulWidget {
  const AddPasswordScreen({Key? key}) : super(key: key);

  static const routeName = '/addPassword';

  @override
  State<StatefulWidget> createState() => _AddPasswordScreen();
}

class _AddPasswordScreen extends State<AddPasswordScreen> {
  late Widget _backButton;

  @override
  void initState() {
    super.initState();
    _backButton = getBackButton(context);
  }

  @override
  Widget build(BuildContext context) {
    final Password? _password =
        ModalRoute.of(context)!.settings.arguments as Password?;
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
        title: _password == null
            ? const Text('Add Password')
            : const Text('Edit Password'),
      ),
    );
  }
}
