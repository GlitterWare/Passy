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

  Widget _buildRecord(String title, String value,
          {bool obscureValue = false}) =>
      Padding(
        padding: entryRecordPadding,
        child: DoubleActionButton(
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(color: lightContentSecondaryColor),
              ),
              Text(obscureValue ? '\u2022' * 6 : value),
            ],
          ),
          icon: const Icon(Icons.copy),
          onButtonPressed: () {},
          onActionPressed: () => Clipboard.setData(ClipboardData(text: value)),
        ),
      );

  //TODO: implement tags
  //TODO: implement customFields

  @override
  Widget build(BuildContext context) {
    final Password _password =
        ModalRoute.of(context)!.settings.arguments as Password;

    List<Widget> _buildRecords() {
      List<Widget> _records = [];
      if (_password.nickname != '') {
        _records.add(_buildRecord('Nickname', _password.nickname));
      }
      if (_password.username != '') {
        _records.add(_buildRecord('Username', _password.username));
      }
      if (_password.email != '') {
        _records.add(_buildRecord('Email', _password.email));
      }
      if (_password.password != '') {
        _records.add(
            _buildRecord('Password', _password.password, obscureValue: true));
      }
      if (_password.tfa != null) {
        _records.add(_buildRecord(
            '2FA Code',
            _password.tfa != null
                ? OTP.generateTOTPCodeString(
                    _password.tfa!.secret,
                    DateTime.now().millisecondsSinceEpoch,
                    length: _password.tfa!.length,
                    interval: _password.tfa!.interval,
                    algorithm: _password.tfa!.algorithm,
                    isGoogle: _password.tfa!.isGoogle,
                  )
                : ''));
      }
      if (_password.website != '') {
        _records.add(_buildRecord('Website', _password.website));
      }
      if (_password.additionalInfo != '') {
        _records.add(_buildRecord('Additional Info', _password.additionalInfo));
      }
      return _records;
    }

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
        children: _buildRecords(),
      ),
    );
  }
}
