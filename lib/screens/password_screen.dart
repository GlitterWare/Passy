import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/password.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  static const routeName = '/main/password';

  @override
  State<StatefulWidget> createState() => _PasswordScreen();
}

class _PasswordScreen extends State<PasswordScreen> {
  Widget? _backButton;

  @override
  void initState() {
    super.initState();
    _backButton = getBackButton(context);
  }

  //TODO: implement OTP display

  @override
  Widget build(BuildContext context) {
    final Password _password =
        ModalRoute.of(context)!.settings.arguments as Password;
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
        title: const Center(child: Text('Password')),
      ),
    );
  }
}
