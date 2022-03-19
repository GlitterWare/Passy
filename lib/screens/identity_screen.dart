import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy/identity.dart';

class IdentityScreen extends StatefulWidget {
  const IdentityScreen({Key? key}) : super(key: key);

  static const routeName = '/identity';

  @override
  State<StatefulWidget> createState() => _IdentityScreen();
}

class _IdentityScreen extends State<IdentityScreen> {
  Widget? _backButton;

  @override
  void initState() {
    super.initState();
    _backButton = getBackButton(context);
  }

  @override
  Widget build(BuildContext context) {
    final Identity _identity =
        ModalRoute.of(context)!.settings.arguments as Identity;
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
      ),
    );
  }
}
