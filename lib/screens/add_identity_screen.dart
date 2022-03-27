import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';

class AddIdentityScreen extends StatefulWidget {
  const AddIdentityScreen({Key? key}) : super(key: key);

  static const routeName = '/addIdentity';

  @override
  State<StatefulWidget> createState() => _AddIdentityScreen();
}

class _AddIdentityScreen extends State<AddIdentityScreen> {
  late Widget _backButton;

  @override
  void initState() {
    super.initState();
    _backButton = getBackButton(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: _backButton,
          title: const Center(child: Text('Add Identity'))),
    );
  }
}
