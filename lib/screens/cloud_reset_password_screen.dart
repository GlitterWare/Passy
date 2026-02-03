import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/passy_cloud.dart';

class CloudResetPasswordScreenArgs {
  final String email;

  const CloudResetPasswordScreenArgs({required this.email});
}

class CloudResetPasswordScreen extends StatefulWidget {
  static const routeName = '/main/cloudManage/cloudResetPassword';

  const CloudResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<CloudResetPasswordScreen> createState() =>
      _CloudResetPasswordScreenState();
}

class _CloudResetPasswordScreenState extends State<CloudResetPasswordScreen> {
  final _account = data.loadedAccount!;

  String _code = '';
  bool _isCapsLockEnabled = false;
  bool _initialized = false;
  bool _isError = false;

  void _resetPassword(String email) async {
    try {
      Password password = Password(
        key: 'gw_cloud',
        nickname: 'Passy Cloud',
        email: email,
        password: PassyGen.generateComplexPassword(),
        websites: [
          'https://glitterware.github.io/',
        ],
      );

      await PassyCloud.confirmPasswordChange(
        email: email,
        code: _code,
        newPassword: password.password,
        confirmPassword: password.password,
      );
      final resp = await PassyCloud.login(
        email: email,
        password: password.password,
      );
      _account.cloudToken = resp.token;
      _account.cloudRefreshToken = resp.refresh;
      await _account.saveSettings();
      await _account.setPassword(password);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.cloudPasswordChanged),
          content: Text(localizations.cloudPasswordChanged),
          actions: [
            TextButton(
              child: Text(localizations.done),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      Navigator.pop(context);
    } finally {
      Navigator.pop(context);
    }
  }

  void _sendRequest(String email) async {
    try {
      await PassyCloud.requestPasswordChange(email: email);
    } catch (_) {
      setState(() => _isError = true);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as CloudResetPasswordScreenArgs;
    if (!_initialized) {
      _sendRequest(args.email);
      _initialized = true;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.resetPassword),
        centerTitle: true,
      ),
      body: Column(
          children: _isError
              ? [
                  Center(
                      child: PassyPadding(
                          Text(localizations.failedToSendConfirmationCode))),
                ]
              : [
                  PassyPadding(Text(
                      localizations.confirmationCodeHasBeenSentToYourEmail)),
                  PassyPadding(Row(
                    children: [
                      if (_isCapsLockEnabled)
                        const PassyPadding(Icon(
                          Icons.arrow_upward_rounded,
                          color: Color.fromRGBO(255, 82, 82, 1),
                        )),
                      Expanded(
                        child: TextField(
                          obscureText: true,
                          onChanged: (s) => setState(() {
                            if (HardwareKeyboard.instance.lockModesEnabled
                                .contains(KeyboardLockMode.capsLock)) {
                              _isCapsLockEnabled = true;
                            } else {
                              _isCapsLockEnabled = false;
                            }
                            _code = s;
                          }),
                          onSubmitted: (s) => _resetPassword(args.email),
                          decoration: InputDecoration(
                            hintText: localizations.confirmationCode,
                          ),
                          autofocus: true,
                        ),
                      ),
                      FloatingActionButton(
                        heroTag: 'cloudButton',
                        onPressed: () => _resetPassword(args.email),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ),
                    ],
                  )),
                ]),
    );
  }
}
