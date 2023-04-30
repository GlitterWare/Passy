import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/tfa.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/screens/common.dart';

import 'edit_password_screen.dart';
import 'main_screen.dart';
import 'passwords_screen.dart';
import 'splash_screen.dart';

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
  Color _tfaColor = PassyTheme.lightContentSecondaryColor;
  bool isFavorite = false;

  Future<void> _generateTFA(TFA tfa) async {
    double _tfaProgressLast = 1.0;

    while (true) {
      if (_onClosed.isCompleted) return;
      double _tfaCycles =
          (DateTime.now().millisecondsSinceEpoch / 1000) / tfa.interval;
      setState(() {
        _tfaProgress = _tfaCycles - _tfaCycles.floor();
      });
      switch (_tfaColor.value) {
        case 4287679225:
          // Blue
          if (_tfaProgress < 0.60) break;
          setState(() {
            _tfaColor = Colors.yellow;
          });
          break;
        case 4294961979:
          // Yellow
          if (_tfaProgress < 0.85) break;
          setState(() {
            _tfaColor = Colors.red;
          });
          break;
        case 4294198070:
          // Red
          if (_tfaProgress > 0.60) break;
          setState(() {
            _tfaColor = PassyTheme.lightContentSecondaryColor;
          });
          break;
      }
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
      await Future.delayed(const Duration(milliseconds: 50));
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
            title: Text(localizations.removePassword),
            content:
                Text('${localizations.passwordsCanOnlyBeRestoredFromABackup}.'),
            actions: [
              TextButton(
                child: Text(
                  localizations.cancel,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  localizations.remove,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, SplashScreen.routeName);
                  _account.removePassword(password.key).whenComplete(() {
                    Navigator.popUntil(context,
                        (r) => r.settings.name == MainScreen.routeName);
                    Navigator.pushNamed(context, PasswordsScreen.routeName);
                  });
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
    isFavorite =
        _account.favoritePasswords[password!.key]?.status == EntryStatus.alive;

    return Scaffold(
      appBar: EntryScreenAppBar(
        entryType: EntryType.password,
        entryKey: password!.key,
        title: Center(child: Text(localizations.password)),
        onRemovePressed: () => _onRemovePressed(password!),
        onEditPressed: () => _onEditPressed(password!),
        isFavorite: isFavorite,
        onFavoritePressed: () async {
          if (isFavorite) {
            await _account.removeFavoritePassword(password!.key);
            showSnackBar(context,
                message: localizations.removedFromFavorites,
                icon: const Icon(
                  Icons.star_outline_rounded,
                  color: PassyTheme.darkContentColor,
                ));
          } else {
            await _account.addFavoritePassword(password!.key);
            showSnackBar(context,
                message: localizations.addedToFavorites,
                icon: const Icon(
                  Icons.star_rounded,
                  color: PassyTheme.darkContentColor,
                ));
          }
          setState(() {});
        },
      ),
      body: ListView(
        children: [
          if (password!.nickname != '')
            PassyPadding(RecordButton(
              title: localizations.nickname,
              value: password!.nickname,
            )),
          if (password!.username != '')
            PassyPadding(RecordButton(
              title: localizations.username,
              value: password!.username,
            )),
          if (password!.email != '')
            PassyPadding(RecordButton(
                title: localizations.email, value: password!.email)),
          if (password!.password != '')
            PassyPadding(RecordButton(
              title: localizations.password,
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
                    color: _tfaColor,
                  ),
                ),
                Flexible(
                  child: PassyPadding(RecordButton(
                    title: localizations.tfaCode,
                    value: _tfaCode,
                  )),
                ),
              ],
            ),
          if (password!.website != '')
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: PassyTheme.passyPadding.left,
                      bottom: PassyTheme.passyPadding.bottom,
                      top: PassyTheme.passyPadding.top,
                    ),
                    child: RecordButton(
                      title: localizations.website,
                      value: password!.website,
                      left: FavIconImage(address: password!.website, width: 40),
                    ),
                  ),
                ),
                SizedBox(
                  child: PassyPadding(
                    FloatingActionButton(
                      heroTag: null,
                      tooltip: localizations.visit,
                      onPressed: () {
                        String _url = password!.website;
                        if (!_url
                            .contains(RegExp('http:\\/\\/|https:\\/\\/'))) {
                          _url = 'http://' + _url;
                        }
                        try {
                          openUrl(_url);
                        } catch (_) {}
                      },
                      child: const Icon(Icons.open_in_browser_rounded),
                    ),
                  ),
                )
              ],
            ),
          for (CustomField _customField in password!.customFields)
            PassyPadding(CustomFieldButton(customField: _customField)),
          if (password!.additionalInfo != '')
            PassyPadding(RecordButton(
                title: localizations.additionalInfo,
                value: password!.additionalInfo)),
        ],
      ),
    );
  }
}
