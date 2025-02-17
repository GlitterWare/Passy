import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/interval_unit.dart';
import 'package:passy/passy_data/key_derivation_type.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/key_derivation_screen.dart';
import 'package:flutter_secure_screen/flutter_secure_screen.dart';
import 'package:text_divider/text_divider.dart';

import 'biometric_auth_screen.dart';
import 'change_password_screen.dart';
import 'change_username_screen.dart';
import 'common.dart';

class SecurityScreen extends StatefulWidget {
  static const routeName = '/security';

  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SecurityScreen();
}

class _SecurityScreen extends State<SecurityScreen> {
  final LoadedAccount loadedAccount = data.loadedAccount!;
  int _screenLockDelay = 15;
  String _screenLockDelayString = '';
  UniqueKey _screenLockDelayKey = UniqueKey();
  IntervalUnit _screenLockDelayUnits = IntervalUnit.seconds;

  void setProtectScreen(bool value) {
    setState(() {
      loadedAccount.protectScreen = value;
    });
    if (Platform.isAndroid) {
      FlutterSecureScreen.singleton
          .setAndroidScreenSecure(loadedAccount.protectScreen);
    }
    loadedAccount.saveSettings();
  }

  void setAutoScreenLock(bool value) {
    setState(() {
      loadedAccount.autoScreenLock = value;
    });
    loadedAccount.saveSettings();
  }

  void loadScreenLockDelayUnits() {
    int _intervalMs = loadedAccount.autoScreenLockDelay;
    bool _setInterval(IntervalUnit unit) {
      double _interval =
          _intervalMs.toDouble() / IntervalUnitsInMilliseconds.getByUnit(unit);
      int _intervalInt = _interval.toInt();
      if (_intervalInt != _interval) return false;
      _screenLockDelayUnits = unit;
      _screenLockDelay = _intervalInt;
      return true;
    }

    if (_setInterval(IntervalUnit.years)) return;
    if (_setInterval(IntervalUnit.months)) return;
    if (_setInterval(IntervalUnit.weeks)) return;
    if (_setInterval(IntervalUnit.days)) return;
    if (_setInterval(IntervalUnit.hours)) return;
    if (_setInterval(IntervalUnit.minutes)) return;
    if (_setInterval(IntervalUnit.seconds)) return;
  }

  void resetScreenLockDelayUnits() {
    loadScreenLockDelayUnits();
    setState(() {
      _screenLockDelayString = _screenLockDelay.toString();
      _screenLockDelayKey = UniqueKey();
    });
  }

  Future<void> saveScreenLockDelayUnits() async {
    if (_screenLockDelayString == '') {
      _screenLockDelay = 0;
    } else {
      _screenLockDelay = int.parse(_screenLockDelayString);
    }
    setState(() {
      loadedAccount.autoScreenLockDelay =
          IntervalUnitsInMilliseconds.toMilliseconds(
              value: _screenLockDelay, unit: _screenLockDelayUnits);
    });
    await loadedAccount.save();
  }

  @override
  void initState() {
    super.initState();
    loadScreenLockDelayUnits();
    _screenLockDelayString = _screenLockDelay.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.security),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          if (Platform.isAndroid || Platform.isIOS)
            PassyPadding(ThreeWidgetButton(
              center: Text(localizations.biometricAuthentication),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.fingerprint_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () =>
                  Navigator.pushNamed(context, BiometricAuthScreen.routeName),
            )),
          if (Platform.isAndroid)
            PassyPadding(ThreeWidgetButton(
              center: Text(localizations.protectScreen),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.smart_display),
              ),
              right: Switch(
                activeColor: Colors.greenAccent,
                value: loadedAccount.protectScreen,
                onChanged: (value) => setProtectScreen(value),
              ),
              onPressed: () => setProtectScreen(!loadedAccount.protectScreen),
            )),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.automaticScreenLock),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.security),
            ),
            right: Switch(
              activeColor: Colors.greenAccent,
              value: loadedAccount.autoScreenLock,
              onChanged: (value) => setAutoScreenLock(value),
            ),
            onPressed: () => setAutoScreenLock(!loadedAccount.autoScreenLock),
          )),
          if (loadedAccount.autoScreenLock) ...[
            TextDivider.horizontal(
              color: PassyTheme.of(context).highlightContentSecondaryColor,
              text: Text(
                localizations.screenLockDelay,
                style: TextStyle(
                    color:
                        PassyTheme.of(context).highlightContentSecondaryColor),
              ),
            ),
            PassyPadding(Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: TextFormField(
                    key: _screenLockDelayKey,
                    initialValue: _screenLockDelayString,
                    onChanged: (value) =>
                        setState(() => _screenLockDelayString = value),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: EnumDropDownButtonFormField<IntervalUnit>(
                    isExpanded: true,
                    value: _screenLockDelayUnits,
                    values: IntervalUnit.values,
                    itemBuilder: (unit) {
                      switch (unit) {
                        case IntervalUnit.years:
                          return Text(localizations.years.toLowerCase());
                        case IntervalUnit.months:
                          return Text(localizations.months.toLowerCase());
                        case IntervalUnit.weeks:
                          return Text(localizations.weeks.toLowerCase());
                        case IntervalUnit.days:
                          return Text(localizations.days.toLowerCase());
                        case IntervalUnit.hours:
                          return Text(localizations.hours.toLowerCase());
                        case IntervalUnit.minutes:
                          return Text(localizations.minutes.toLowerCase());
                        case IntervalUnit.seconds:
                          return Text(localizations.seconds.toLowerCase());
                      }
                    },
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _screenLockDelayUnits = value);
                    },
                  ),
                ),
                FloatingActionButton(
                  heroTag: null,
                  child: const Icon(Icons.close),
                  onPressed: resetScreenLockDelayUnits,
                  tooltip: localizations.reset,
                ),
                FloatingActionButton(
                  heroTag: null,
                  child: const Icon(Icons.save),
                  onPressed: saveScreenLockDelayUnits,
                  tooltip: localizations.save,
                ),
              ],
            )),
          ],
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.changeUsername),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.person_outline_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, ChangeUsernameScreen.routeName),
          )),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.changePassword),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.lock_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, ChangePasswordScreen.routeName),
          )),
          PassyPadding(ThreeWidgetButton(
            color:
                (loadedAccount.keyDerivationType == KeyDerivationType.none) &&
                        recommendKeyDerivation
                    ? const Color.fromRGBO(255, 82, 82, 1)
                    : null,
            center: Text(localizations.keyDerivation),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.key_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, KeyDerivationScreen.routeName)
                    .then(
              (value) => setState(() {}),
            ),
          )),
        ],
      ),
    );
  }
}
