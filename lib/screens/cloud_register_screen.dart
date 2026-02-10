import 'dart:io';

import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/main.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/passy_cloud.dart';
import 'package:flutter/services.dart';

import 'cloud_privacy_policy_screen.dart';
import 'cloud_manage_screen.dart';
import 'splash_screen.dart';
import 'log_screen.dart';

class CloudRegisterScreen extends StatefulWidget {
  static const String routeName = '/main/cloudRegister';

  const CloudRegisterScreen({Key? key}) : super(key: key);

  @override
  _CloudRegisterScreenState createState() => _CloudRegisterScreenState();
}

class _CloudRegisterScreenState extends State<CloudRegisterScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  String _email = '';
  String _code = '';
  bool _isLogin = false;
  bool _isCodeSent = false;
  bool _isCapsLockEnabled = false;
  final TextEditingController _emailController = TextEditingController();

  Future<void> _onAccepted() async {
    Navigator.pushNamed(context, SplashScreen.routeName);
    Password newPassword = Password(
      key: 'gw_cloud_new',
      nickname: 'Passy Cloud',
      email: _email,
      password: PassyGen.generateComplexPassword(),
      websites: [
        'https://glitterware.github.io/',
      ],
    );
    try {
      await PassyCloud.register(
        email: _email,
        password: newPassword.password,
        acceptPrivacy: true,
        acceptTerms: true,
      );
      if (!_account.passwordExists('gw_cloud') &&
          !_account.passwordExists('gw_cloud_new')) {
        await _account.setPassword(newPassword);
      }
      await PassyCloud.requestLoginCode(email: _email);
      setState(() {
        _isLogin = true;
        _isCodeSent = true;
      });
    } catch (e, s) {
      showSnackBar(
        message: localizations.cloudError,
        icon: const Icon(Icons.cloud_off_rounded),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(
              navigatorKey.currentContext!, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> _login() async {
    try {
      Navigator.pushNamed(context, SplashScreen.routeName);
      final r =
          await PassyCloud.loginWithCode(email: _email, code: _code);
      _account.cloudToken = r.token;
      _account.cloudRefreshToken = r.refresh;
      _account.cloudEnabled = true;
      await _account.saveSettings();
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, CloudManageScreen.routeName);
    } catch (e, s) {
      Navigator.pop(context);
      if (e is PassyCloudError) {
        if (e.statusCode == HttpStatus.unauthorized) {
          showSnackBar(
              message: localizations.invalidOrExpiredConfirmationCode,
              icon: const Icon(Icons.lock_rounded));
          return;
        }
      }
      showSnackBar(
        message: localizations.cloudError,
        icon: const Icon(Icons.cloud_off_rounded),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(
              navigatorKey.currentContext!, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Widget buildRegistration() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passy Cloud'),
        centerTitle: true,
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const Spacer(),
          Flexible(
              child: SvgPicture.asset('assets/images/passy_cloud.svg',
                  height: 500),
              flex: 2),
          Center(
              child: PassyPadding(Text.rich(
            style: const TextStyle(
              height: 1.5,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            FormattedTextParser(context: context)
                .parse(text: localizations.passyCloudTagline),
          ))),
          PassyPadding(Text('* ' + localizations.premiumFeature,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ))),
          PassyPadding(TextFormField(
            controller: _emailController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: localizations.email,
              alignLabelWithHint: true,
            ),
            onChanged: (s) => setState(() => _email = s),
          )),
          if (_isLogin && !_isCodeSent)
            PassyPadding(FloatingActionButton.extended(
              heroTag: 'cloudButton',
              label: Text(localizations.logIn),
              onPressed: () async {
                try {
                  await PassyCloud.requestLoginCode(email: _email);
                  setState(() => _isCodeSent = true);
                } catch (e) {
                  if (e is! PassyCloudError) rethrow;
                  if (e.statusCode != HttpStatus.badRequest) rethrow;
                  showSnackBar(
                      message: localizations.pleaseEnterAValidEmail,
                      icon: const Icon(
                        Icons.email_rounded,
                      ));
                }
              },
            )),
          if (_isLogin && _isCodeSent)
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
                    onSubmitted: (s) => _login(),
                    decoration: InputDecoration(
                      hintText: localizations.confirmationCode,
                    ),
                    autofocus: true,
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'cloudButton',
                  onPressed: () => _login(),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                  ),
                  tooltip: localizations.logIn,
                ),
              ],
            )),
          if (!_isLogin)
            PassyPadding(FloatingActionButton.extended(
              heroTag: 'cloudButton',
              label: Text(localizations.enableCloudSync),
              onPressed: () => Navigator.pushNamed(
                      context, CloudPrivacyPolicyScreen.routeName)
                  .then((value) async {
                if (value == null) return;
                if (value == false) Navigator.pop(context);
                if (value == true) _onAccepted();
              }),
            )),
          if (!_isLogin) const Spacer(),
          if (!_isLogin) PassyPadding(Text(localizations.alreadyAMember)),
          if (!_isLogin)
            TextButton(
              child: Text(localizations.logIn,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: PassyTheme.of(context)
                          .highlightContentSecondaryColor)),
              onPressed: () => setState(() {
                Password? password = _account.getPassword('gw_cloud');
                if (password != null) {
                  _emailController.text = password.email;
                  _email = password.email;
                }
                _isLogin = true;
              }),
            ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget buildManagement() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Passy Cloud"),
        centerTitle: true,
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_account.cloudEnabled) return buildRegistration();
    return buildRegistration();
    //return buildManagement();
  }
}
