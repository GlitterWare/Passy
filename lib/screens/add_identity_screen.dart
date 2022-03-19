import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy/identity.dart';

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
    final Identity? _identity =
        ModalRoute.of(context)!.settings.arguments as Identity?;
    return Scaffold(
      appBar: AppBar(
          leading: _backButton,
          title: _identity == null
              ? const Text('Add Identity')
              : const Text('Edit Identity')),
    );
  }
}
