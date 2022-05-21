import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';

import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/tfa.dart';
import 'package:passy/screens/edit_password_screen.dart';
import 'package:passy/widgets/back_button.dart';
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
  final Completer<void> _onClosed = Completer<void>();
  final Completer<Password> _onPasswordLoaded = Completer<Password>();
  final LoadedAccount _account = data.loadedAccount!;
  String _tfaCode = '';
  double _tfaProgress = 0;

  Future<void> _generateTFA(TFA tfa) async {
    double _tfaProgressLast = 1.0;

    while (true) {
      if (_onClosed.isCompleted) return;
      double _tfaCycles =
          (DateTime.now().millisecondsSinceEpoch / 1000) / tfa.interval;
      setState(() {
        _tfaProgress = _tfaCycles - _tfaCycles.floor();
      });
      if (_tfaProgress < _tfaProgressLast) {
        setState(() {
          _tfaCode = OTP.generateTOTPCodeString(
            tfa.secret,
            DateTime.now().millisecondsSinceEpoch,
            length: tfa.length,
            interval: tfa.interval,
            algorithm: tfa.algorithm,
            isGoogle: tfa.isGoogle,
          );
        });
      }
      _tfaProgressLast = _tfaProgress;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Widget _buildRecord(String title, String value,
          {bool obscureValue = false, bool isPassword = false}) =>
      DoubleActionButton(
        body: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: lightContentSecondaryColor),
            ),
            Text(
              obscureValue ? '\u2022' * 6 : value,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        icon: const Icon(Icons.copy),
        onButtonPressed: () => showDialog(
          context: context,
          builder: (_) =>
              getRecordDialog(value: value, highlightSpecial: isPassword),
        ),
        onActionPressed: () => Clipboard.setData(ClipboardData(text: value)),
      );

  //TODO: implement tags

  @override
  void initState() {
    super.initState();
    _onPasswordLoaded.future.then((p) {
      if (p.tfa == null) return;
      _generateTFA(p.tfa!);
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    _onClosed.complete();
  }

  @override
  Widget build(BuildContext context) {
    final Password _password =
        ModalRoute.of(context)!.settings.arguments as Password;
    if (!_onPasswordLoaded.isCompleted) _onPasswordLoaded.complete(_password);
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
        _records.add(_buildRecord(
          'Password',
          _password.password,
          obscureValue: true,
          isPassword: true,
        ));
      }
      if (_password.tfa != null) {
        _records.add(Row(
          children: [
            SizedBox(
              width: entryPadding.left * 2,
            ),
            SizedBox(
              child: CircularProgressIndicator(
                value: _tfaProgress,
                color: lightContentSecondaryColor,
              ),
            ),
            Flexible(
              child: _buildRecord('2FA Code', _tfaCode),
            ),
          ],
        ));
      }
      if (_password.website != '') {
        _records.add(_buildRecord('Website', _password.website));
      }
      for (CustomField _customField in _password.customFields) {
        _records.add(_buildRecord(_customField.title, _customField.value,
            obscureValue: _customField.obscured,
            isPassword: _customField.fieldType == FieldType.password));
      }
      if (_password.additionalInfo != '') {
        _records.add(_buildRecord('Additional Info', _password.additionalInfo));
      }
      return _records;
    }

    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(child: Text(_password.nickname)),
        actions: [
          IconButton(
            padding: appBarButtonPadding,
            splashRadius: appBarButtonSplashRadius,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      shape: dialogShape,
                      title: const Text('Remove password'),
                      content: const Text(
                          'Passwords can only be restored from a backup.'),
                      actions: [
                        TextButton(
                          child: Text(
                            'No',
                            style: TextStyle(color: lightContentSecondaryColor),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: Text(
                            'Yes',
                            style: TextStyle(color: lightContentSecondaryColor),
                          ),
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
            padding: appBarButtonPadding,
            splashRadius: appBarButtonSplashRadius,
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.pushNamed(context, EditPasswordScreen.routeName,
                  arguments: _password);
            },
          ),
        ],
      ),
      body: ListView(
        children: _buildRecords(),
      ),
    );
  }
}
