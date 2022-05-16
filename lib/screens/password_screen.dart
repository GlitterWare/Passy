import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';

import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/screens/edit_password_screen.dart';
import 'package:passy/widgets/double_action_button.dart';

import 'main_screen.dart';
import 'passwords_screen.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  static const routeName = '/main/password';

  @override
  State<StatefulWidget> createState() => _PasswordScreen();
}

class _PasswordScreen extends State<PasswordScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  Widget? _backButton;

  @override
  void initState() {
    super.initState();
    _backButton = getBackButton(
      onPressed: () => Navigator.pop(context),
    );
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text('Remove password'),
                      content: const Text(
                          'Password can only be restored from a backup.'),
                      actions: [
                        TextButton(
                          child: const Text('No'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () {
                            _account.removePassword(_password.key);
                            Navigator.popUntil(context,
                                (r) => r.settings.name == MainScreen.routeName);
                            _account.save().whenComplete(() =>
                                Navigator.pushNamed(
                                    context, PasswordsScreen.routeName));
                          },
                        )
                      ],
                    );
                  });
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.pushNamed(context, EditPasswordScreen.routeName,
                  arguments: _password);
            },
          ),
        ],
      ),
      body: ListView(
        padding: entryRecordPadding,
        children: [
          Padding(
            padding: entryRecordPadding,
            child: DoubleActionButton(
              child: Column(
                children: [
                  Text(
                    'Nickname',
                    style: TextStyle(color: Colors.blue[200]),
                  ),
                  Text(_password.nickname),
                ],
              ),
              icon: const Icon(Icons.copy),
              onButtonPressed: () {},
              onActionPressed: () =>
                  Clipboard.setData(ClipboardData(text: _password.nickname)),
            ),
          ),
          Padding(
            padding: entryRecordPadding,
            child: DoubleActionButton(
              child: Column(
                children: [
                  Text(
                    'Username',
                    style: TextStyle(color: Colors.blue[200]),
                  ),
                  Text(_password.username),
                ],
              ),
              icon: const Icon(Icons.copy),
              onButtonPressed: () {},
              onActionPressed: () =>
                  Clipboard.setData(ClipboardData(text: _password.username)),
            ),
          ),
          Padding(
            padding: entryRecordPadding,
            child: DoubleActionButton(
              child: Column(
                children: [
                  Text(
                    'Email',
                    style: TextStyle(color: Colors.blue[200]),
                  ),
                  Text(_password.email),
                ],
              ),
              icon: const Icon(Icons.copy),
              onButtonPressed: () {},
              onActionPressed: () =>
                  Clipboard.setData(ClipboardData(text: _password.email)),
            ),
          ),
          Padding(
            padding: entryRecordPadding,
            child: DoubleActionButton(
              child: Column(
                children: [
                  Text(
                    'Password',
                    style: TextStyle(color: Colors.blue[200]),
                  ),
                  Text(_password.password),
                ],
              ),
              icon: const Icon(Icons.copy),
              onButtonPressed: () {},
              onActionPressed: () =>
                  Clipboard.setData(ClipboardData(text: _password.password)),
            ),
          ),
          Padding(
            padding: entryRecordPadding,
            child: DoubleActionButton(
              child: Column(
                children: [
                  Text(
                    '2FA Code',
                    style: TextStyle(color: Colors.blue[200]),
                  ),
                  _password.tfa != null
                      ? Text(OTP.generateTOTPCodeString(
                          _password.tfa!.secret,
                          DateTime.now().millisecondsSinceEpoch,
                          length: _password.tfa!.length,
                          interval: _password.tfa!.interval,
                          algorithm: _password.tfa!.algorithm,
                          isGoogle: _password.tfa!.isGoogle,
                        ))
                      : const Text(''),
                ],
              ),
              icon: const Icon(Icons.copy),
              onButtonPressed: () {},
              onActionPressed: () {
                if (_password.tfa == null) return;
                Clipboard.setData(ClipboardData(
                  text: OTP.generateTOTPCodeString(
                    _password.tfa!.secret,
                    DateTime.now().millisecondsSinceEpoch,
                    length: _password.tfa!.length,
                    interval: _password.tfa!.interval,
                    algorithm: _password.tfa!.algorithm,
                    isGoogle: _password.tfa!.isGoogle,
                  ),
                ));
              },
            ),
          ),
          Padding(
            padding: entryRecordPadding,
            child: DoubleActionButton(
              child: Column(
                children: [
                  Text(
                    'Website',
                    style: TextStyle(color: Colors.blue[200]),
                  ),
                  Text(_password.website),
                ],
              ),
              icon: const Icon(Icons.copy),
              onButtonPressed: () {},
              onActionPressed: () =>
                  Clipboard.setData(ClipboardData(text: _password.website)),
            ),
          ),
          Padding(
            padding: entryRecordPadding,
            child: DoubleActionButton(
              child: Column(
                children: [
                  Text(
                    'Additional Info',
                    style: TextStyle(color: Colors.blue[200]),
                  ),
                  Text(_password.additionalInfo),
                ],
              ),
              icon: const Icon(Icons.copy),
              onButtonPressed: () {},
              onActionPressed: () => Clipboard.setData(
                  ClipboardData(text: _password.additionalInfo)),
            ),
          ),
        ],
      ),
    );
  }
}
