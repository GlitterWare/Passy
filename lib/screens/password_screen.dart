import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/tfa.dart';
import 'package:passy/widgets/widgets.dart';

import '../common/theme.dart';
import 'edit_password_screen.dart';
import 'common.dart';
import 'main_screen.dart';
import 'passwords_screen.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  static const routeName = '/password';

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

  void _onRemovePressed(Password password) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: dialogShape,
            title: const Text('Remove password'),
            content:
                const Text('Passwords can only be restored from a backup.'),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  'Remove',
                  style: TextStyle(color: lightContentSecondaryColor),
                ),
                onPressed: () {
                  _account.removePassword(password.key);
                  Navigator.popUntil(
                      context, (r) => r.settings.name == MainScreen.routeName);
                  _account.save().whenComplete(() =>
                      Navigator.pushNamed(context, PasswordsScreen.routeName));
                },
              )
            ],
          );
        });
  }

  void _onEditPressed(Password password) {
    Navigator.pushNamed(
      context,
      EditPasswordScreen.routeName,
      arguments: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Password _password =
        ModalRoute.of(context)!.settings.arguments as Password;
    if (!_onPasswordLoaded.isCompleted) _onPasswordLoaded.complete(_password);

    return Scaffold(
      appBar: getEntryScreenAppBar(
        context,
        title: const Center(child: Text('Password')),
        onRemovePressed: () => _onRemovePressed(_password),
        onEditPressed: () => _onEditPressed(_password),
      ),
      body: ListView(
        children: [
          if (_password.nickname != '')
            PassyPadding(PassyRecord(
              title: 'Nickname',
              value: _password.nickname,
            )),
          if (_password.username != '')
            PassyPadding(PassyRecord(
              title: 'Username',
              value: _password.username,
            )),
          if (_password.email != '')
            PassyPadding(PassyRecord(title: 'Email', value: _password.email)),
          if (_password.password != '')
            PassyPadding(PassyRecord(
              title: 'Password',
              value: _password.password,
              obscureValue: true,
              isPassword: true,
            )),
          if (_password.tfa != null)
            Row(
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
                  child: PassyPadding(PassyRecord(
                    title: '2FA code',
                    value: _tfaCode,
                  )),
                ),
              ],
            ),
          if (_password.website != '')
            Stack(children: [
              PassyPadding(PassyRecord(
                title: 'Website',
                value: _password.website,
              )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(23, 18, 0, 0),
                  child: getFavIcon(_password.website, width: 35)),
            ]),
          for (CustomField _customField in _password.customFields)
            buildCustomField(context, _customField),
          if (_password.additionalInfo != '')
            PassyPadding(PassyRecord(
                title: 'Additional info', value: _password.additionalInfo)),
        ],
      ),
    );
  }
}
