import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:otp/otp.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/tfa.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/passy_flutter/passy_theme.dart';

import 'edit_password_screen.dart';
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
  final LoadedAccount _account = data.loadedAccount!;
  Password? password;
  Future<void>? generateTFA;
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
            shape: PassyTheme.dialogShape,
            title: const Text('Remove password'),
            content:
                const Text('Passwords can only be restored from a backup.'),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style:
                      TextStyle(color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text(
                  'Remove',
                  style:
                      TextStyle(color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () {
                  _account.removePassword(password.key);
                  Navigator.popUntil(
                      context, (r) => r.settings.name == MainScreen.routeName);
                  _account.savePasswords().whenComplete(() =>
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
    if (password == null) {
      password = ModalRoute.of(context)!.settings.arguments as Password;
      if (password!.tfa != null) generateTFA = _generateTFA(password!.tfa!);
    }

    return Scaffold(
      appBar: EntryScreenAppBar(
        title: const Center(child: Text('Password')),
        onRemovePressed: () => _onRemovePressed(password!),
        onEditPressed: () => _onEditPressed(password!),
      ),
      body: ListView(
        children: [
          if (password!.nickname != '')
            PassyPadding(RecordButton(
              title: 'Nickname',
              value: password!.nickname,
            )),
          if (password!.username != '')
            PassyPadding(RecordButton(
              title: 'Username',
              value: password!.username,
            )),
          if (password!.email != '')
            PassyPadding(RecordButton(title: 'Email', value: password!.email)),
          if (password!.password != '')
            PassyPadding(RecordButton(
              title: 'Password',
              value: password!.password,
              obscureValue: true,
              isPassword: true,
            )),
          if (password!.tfa != null)
            Row(
              children: [
                SizedBox(
                  width: PassyTheme.passyPadding.left * 2,
                ),
                SizedBox(
                  child: CircularProgressIndicator(
                    value: _tfaProgress,
                    color: PassyTheme.lightContentSecondaryColor,
                  ),
                ),
                Flexible(
                  child: PassyPadding(RecordButton(
                    title: '2FA code',
                    value: _tfaCode,
                  )),
                ),
              ],
            ),
          if (password!.website != '')
            Row(
              children: [
                Flexible(
                  child: PassyPadding(RecordButton(
                    title: 'Website',
                    value: password!.website,
                    left: FavIconImage(address: password!.website, width: 40),
                  )),
                ),
                SizedBox(
                  child: PassyPadding(FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      String _url = password!.website;
                      if (!_url.contains(RegExp('http:\\/\\/|https:\\/\\/'))) {
                        _url = 'http://' + _url;
                      }
                      try {
                        FlutterWebBrowser.openWebPage(
                          url: _url,
                        );
                      } catch (_) {}
                    },
                    child: const Icon(Icons.open_in_browser_rounded),
                  )),
                )
              ],
            ),
          for (CustomField _customField in password!.customFields)
            PassyPadding(CustomFieldButton(customField: _customField)),
          if (password!.additionalInfo != '')
            PassyPadding(RecordButton(
                title: 'Additional info', value: password!.additionalInfo)),
        ],
      ),
    );
  }
}
