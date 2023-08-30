import 'package:dargon2_flutter/dargon2_flutter.dart';
import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/argon2_info.dart';
import 'package:passy/passy_data/key_derivation_info.dart';
import 'package:passy/passy_data/key_derivation_type.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/main_screen.dart';

import 'common.dart';
import 'security_screen.dart';
import 'splash_screen.dart';

class KeyDerivationScreen extends StatefulWidget {
  static String routeName = '${SecurityScreen.routeName}/keyDerivation';

  const KeyDerivationScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KeyDerivationScreen();
}

class _KeyDerivationScreen extends State<KeyDerivationScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  KeyDerivationType _type = KeyDerivationType.none;
  KeyDerivationInfo? _info;
  String _password = '';
  bool _isChanged = false;

  Future<void> _onConfirmPressed() async {
    if ((await data.createPasswordHash(_account.username,
            password: _password)) !=
        _account.passwordHash) {
      showSnackBar(context,
          message: localizations.incorrectPassword,
          icon: const Icon(
            Icons.lock_rounded,
            color: PassyTheme.darkContentColor,
          ));
      return;
    }
    Navigator.pushNamed(context, SplashScreen.routeName);
    await _account.setAccountPassword(_password,
        derivationType: _type, derivationInfo: _info);
    Navigator.popUntil(context, (route) {
      return route.settings.name == MainScreen.routeName ||
          route.settings.name == SecurityScreen.routeName;
    });
  }

  @override
  void initState() {
    super.initState();
    _type = _account.keyDerivationType;
    _info = _account.keyDerivationInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.keyDerivation),
        centerTitle: true,
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(children: [
              const Spacer(),
              Text(
                localizations.keyDerivationDescription,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PassyPadding(Text(
                localizations.keyDerivationWarning1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: PassyTheme.lightContentSecondaryColor),
              )),
              const SizedBox(height: 24),
              PassyPadding(RichText(
                text: TextSpan(children: [
                  const WidgetSpan(
                      child: Icon(
                    Icons.sync_rounded,
                    size: 15,
                  )),
                  TextSpan(text: '  ${localizations.keyDerivationWarning2}'),
                ]),
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              )),
              const SizedBox(height: 24),
              PassyPadding(RichText(
                text: TextSpan(children: [
                  const WidgetSpan(
                      child: Icon(
                    Icons.update,
                    size: 15,
                  )),
                  TextSpan(text: '  ${localizations.keyDerivationWarning3}'),
                ]),
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              )),
              const SizedBox(height: 24),
              Container(
                child: PassyPadding(DropdownButtonFormField<KeyDerivationType>(
                  items: [
                    DropdownMenuItem(
                      child: Text(
                          'Argon2 (${localizations.recommended.toLowerCase()})'),
                      value: KeyDerivationType.argon2,
                    ),
                    DropdownMenuItem(
                      child: Text(localizations.none),
                      value: KeyDerivationType.none,
                    ),
                  ],
                  value: _type,
                  decoration: InputDecoration(
                      labelText: localizations.keyDerivationType),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _isChanged = true;
                      _type = value;
                      switch (_type) {
                        case KeyDerivationType.none:
                          _info = null;
                          break;
                        case KeyDerivationType.argon2:
                          _info = Argon2Info(salt: Salt.newSalt());
                          break;
                      }
                    });
                  },
                )),
                color: _type == KeyDerivationType.none
                    ? const Color.fromRGBO(255, 82, 82, 1)
                    : null,
              ),
              if (_isChanged)
                RichText(
                  text: TextSpan(
                      text: localizations.youAreChangingKeyDerivationFor,
                      children: [
                        TextSpan(
                          text: _account.username,
                          style: const TextStyle(
                            color: PassyTheme.lightContentSecondaryColor,
                          ),
                        ),
                        const TextSpan(text: '.')
                      ]),
                ),
              if (_isChanged)
                Expanded(
                  child: PassyPadding(
                    Column(
                      children: [
                        ButtonedTextFormField(
                          labelText: localizations.currentPassword,
                          obscureText: true,
                          initialValue: _password,
                          onChanged: (s) => setState(() => _password = s),
                          onFieldSubmitted: (s) => _onConfirmPressed(),
                          onPressed: _onConfirmPressed,
                          buttonIcon:
                              const Icon(Icons.arrow_forward_ios_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
            ]),
          ),
        ],
      ),
    );
  }
}
