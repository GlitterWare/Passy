import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/passy_cloud.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/splash_screen.dart';

class CloudUpdateEmailScreenArgs {
  final String oldEmail;

  CloudUpdateEmailScreenArgs({required this.oldEmail});
}

class CloudUpdateEmailScreen extends StatefulWidget {
  static const routeName = '/main/cloudManage/cloudUpdateEmail';

  const CloudUpdateEmailScreen({Key? key}) : super(key: key);

  @override
  State<CloudUpdateEmailScreen> createState() => _CloudUpdateEmailScreenState();
}

class _CloudUpdateEmailScreenState extends State<CloudUpdateEmailScreen> {
  final _account = data.loadedAccount!;

  String _newEmail = '';
  String _oldEmailCode = '';
  String _newEmailCode = '';
  bool _isCapsLockEnabled = false;
  int _step = 0;
  final TextEditingController _textController1 = TextEditingController();
  final TextEditingController _textController2 = TextEditingController();

  void _updateEmail(String oldEmail) async {
    String? token = _account.cloudToken;
    if (token == null) return;
    switch (_step) {
      case 0:
        Navigator.pushNamed(context, SplashScreen.routeName);
        try {
          await PassyCloud.requestEmailChange(
              token: token, newEmail: _newEmail);
          _textController1.clear();
          setState(() => _step = 1);
        } catch (_) {
          rethrow;
        } finally {
          Navigator.pop(context);
        }
        break;
      case 1:
        _textController1.clear();
        _textController2.text = _oldEmailCode;
        setState(() => _step = 2);
        break;
      case 2:
        Navigator.pushNamed(context, SplashScreen.routeName);
        try {
          await PassyCloud.confirmEmailChange(
              token: token,
              oldEmailCode: _oldEmailCode,
              newEmailCode: _newEmailCode);
          var password = _account.getPassword('gw_cloud');
          if (password != null) {
            password.email = _newEmail;
            await _account.setPassword(password);
          }
          await showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                      shape: PassyTheme.dialogShape,
                      title: Text(localizations.emailChanged),
                      content: Text(localizations.emailChanged),
                      actions: [
                        TextButton(
                          child: Text(localizations.done),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ]));
          Navigator.pop(context);
        } finally {
          Navigator.pop(context);
        }
        break;
    }
  }

  @override
  void dispose() {
    _textController1.dispose();
    _textController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CloudUpdateEmailScreenArgs args = ModalRoute.of(context)!.settings.arguments
        as CloudUpdateEmailScreenArgs;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.updateEmailAddress),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_step == 2)
            PassyPadding(
              TextField(
                controller: _textController2,
                onChanged: (s) => setState(() {
                  if (HardwareKeyboard.instance.lockModesEnabled
                      .contains(KeyboardLockMode.capsLock)) {
                    _isCapsLockEnabled = true;
                  } else {
                    _isCapsLockEnabled = false;
                  }
                  _oldEmailCode = s;
                }),
                decoration: InputDecoration(
                  hintText: localizations.codeFromEmail
                      .replaceFirst('%e', args.oldEmail),
                ),
                autofocus: true,
              ),
            ),
          PassyPadding(Row(
            children: [
              if (_isCapsLockEnabled)
                const PassyPadding(Icon(
                  Icons.arrow_upward_rounded,
                  color: Color.fromRGBO(255, 82, 82, 1),
                )),
              Expanded(
                child: TextField(
                  controller: _textController1,
                  onChanged: (s) => setState(() {
                    if (HardwareKeyboard.instance.lockModesEnabled
                        .contains(KeyboardLockMode.capsLock)) {
                      _isCapsLockEnabled = true;
                    } else {
                      _isCapsLockEnabled = false;
                    }
                    switch (_step) {
                      case 0:
                        _newEmail = s;
                        break;
                      case 1:
                        _oldEmailCode = s;
                        break;
                      case 2:
                        _newEmailCode = s;
                        break;
                    }
                  }),
                  onSubmitted: (s) => _updateEmail(args.oldEmail),
                  decoration: InputDecoration(
                    hintText: _step == 0
                        ? localizations.newEmailAddress
                        : _step == 1
                            ? localizations.codeFromEmail
                                .replaceFirst('%e', args.oldEmail)
                            : localizations.codeFromEmail
                                .replaceFirst('%e', _newEmail),
                  ),
                  autofocus: true,
                ),
              ),
              FloatingActionButton(
                heroTag: 'cloudButton',
                onPressed: () => _updateEmail(args.oldEmail),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
