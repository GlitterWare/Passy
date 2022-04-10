import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/widgets/entry_widget.dart';

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
  //TODO: implement tags
  //TODO: implement customFields

  @override
  Widget build(BuildContext context) {
    final Password _password =
        ModalRoute.of(context)!.settings.arguments as Password;
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
        title: Center(child: Text(_password.nickname)),
      ),
      body: ListView(children: [
        EntryWidget(
          body: Column(
            children: [
              const Text(
                'Nickname',
                style: TextStyle(color: Colors.grey),
              ),
              Text(_password.nickname),
            ],
          ),
        ),
        EntryWidget(
          body: Column(
            children: [
              const Text(
                'Username',
                style: TextStyle(color: Colors.grey),
              ),
              Text(_password.username),
            ],
          ),
        ),
        EntryWidget(
          body: Column(
            children: [
              const Text(
                'Email',
                style: TextStyle(color: Colors.grey),
              ),
              Text(_password.email),
            ],
          ),
        ),
        EntryWidget(
          body: Column(
            children: [
              const Text(
                'Password',
                style: TextStyle(color: Colors.grey),
              ),
              Text(_password.password),
            ],
          ),
        ),
        EntryWidget(
          body: Column(
            children: [
              const Text(
                'Website',
                style: TextStyle(color: Colors.grey),
              ),
              Text(_password.website),
            ],
          ),
        ),
        EntryWidget(
          body: Column(
            children: [
              const Text(
                'Additional Info',
                style: TextStyle(color: Colors.grey),
              ),
              Text(_password.additionalInfo),
            ],
          ),
        ),
      ]),
    );
  }
}
