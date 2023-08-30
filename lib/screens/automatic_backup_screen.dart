import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/auto_backup_settings.dart';
import 'package:passy/passy_flutter/common/backup_interval_unit.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'common.dart';
import 'settings_screen.dart';

class AutomaticBackupScreen extends StatefulWidget {
  static const routeName = '${SettingsScreen.routeName}/autoBackup';

  const AutomaticBackupScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutomaticBackupScreen();
}

class _AutomaticBackupScreen extends State<AutomaticBackupScreen> {
  final _account = data.loadedAccount!;
  int _buInterval = 1;
  IntervalUnit _buIntervalUnits = IntervalUnit.weeks;

  Future<void> _onBuIntervalChanged(String value) async {
    if (value == '') return;
    setState(() => _buInterval = int.parse(value));
    int _val = _buInterval;
    switch (_buIntervalUnits) {
      case IntervalUnit.years:
        _val = _val * IntervalUnitsInMilliseconds.year;
        break;
      case IntervalUnit.months:
        _val = _val * IntervalUnitsInMilliseconds.month;
        break;
      case IntervalUnit.weeks:
        _val = _val * IntervalUnitsInMilliseconds.week;
        break;
      case IntervalUnit.days:
        _val = _val * IntervalUnitsInMilliseconds.day;
        break;
      case IntervalUnit.hours:
        _val = _val * IntervalUnitsInMilliseconds.hour;
        break;
      case IntervalUnit.minutes:
        _val = _val * IntervalUnitsInMilliseconds.minute;
        break;
      case IntervalUnit.seconds:
        _val = _val * IntervalUnitsInMilliseconds.second;
        break;
    }
    _account.autoBackup!.lastBackup = DateTime.now().toUtc();
    _account.autoBackup!.backupInterval = _val;
    await _account.saveLocalSettings();
    data.refreshAccounts();
  }

  Future<void> _onBuIntervalUnitsChanged(IntervalUnit? value) async {
    if (value == null) return;
    setState(() => _buIntervalUnits = value);
    await _onBuIntervalChanged(_buInterval.toString());
  }

  Future<void> _disableAutoBackup() async {
    setState(() => _account.autoBackup = null);
    await _account.saveLocalSettings();
    data.refreshAccounts();
  }

  Future<void> _enableAutoBackup() async {
    String _username = _account.username;
    Object? _buException;
    String? _buPath;
    try {
      _buPath = await backupAccount(context, username: _username);
    } catch (e) {
      _buException = e;
    }
    if (_buPath == null) return;
    if (_buException != null) return;
    setState(() {
      _account.autoBackup = AutoBackupSettings(
        path: _buPath!,
        lastBackup: DateTime.now().toUtc(),
      );
    });
    await _onBuIntervalChanged(_buInterval.toString());
  }

  Future<void> _setAutoBackupEnabled(bool value) async {
    if (value == true) {
      await _enableAutoBackup();
      return;
    }
    await _disableAutoBackup();
  }

  @override
  void initState() {
    super.initState();
    if (_account.autoBackup == null) return;
    int _intervalMs = _account.autoBackup!.backupInterval;
    bool _setInterval(IntervalUnit unit) {
      double _interval =
          _intervalMs.toDouble() / IntervalUnitsInMilliseconds.getByUnit(unit);
      int _intervalInt = _interval.toInt();
      if (_intervalInt != _interval) return false;
      _buIntervalUnits = unit;
      _buInterval = _intervalInt;
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
        title: Text(localizations.automaticBackup),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.automaticBackup),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.save_outlined),
            ),
            right: Switch(
              activeColor: Colors.greenAccent,
              value: _account.autoBackup != null,
              onChanged: (value) => _setAutoBackupEnabled(value),
            ),
            onPressed: () =>
                _setAutoBackupEnabled(!(_account.autoBackup != null)),
          )),
          if (_account.autoBackup != null)
            PassyPadding(Row(
              children: [
                Flexible(
                  child: TextFormField(
                    decoration:
                        InputDecoration(labelText: localizations.interval),
                    initialValue: _buInterval.toString(),
                    onChanged: _onBuIntervalChanged,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      FilteringTextInputFormatter.deny(RegExp('^0')),
                    ],
                  ),
                ),
                Flexible(
                  child: EnumDropDownButtonFormField<IntervalUnit>(
                    value: _buIntervalUnits,
                    values: IntervalUnit.values,
                    onChanged: _onBuIntervalUnitsChanged,
                  ),
                )
              ],
            )),
          if (_account.autoBackup != null)
            PassyPadding(ThreeWidgetButton(
              center: Text(localizations.changeBackupPath),
              left: const Padding(
                  padding: EdgeInsets.only(right: 30),
                  child: Icon(Icons.folder_outlined)),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () => _enableAutoBackup(),
            )),
          if (_account.autoBackup != null)
            PassyPadding(
              RichText(
                text: TextSpan(
                  text: localizations.backupPathColon,
                  children: [
                    TextSpan(
                      text: _account.autoBackup!.path,
                      style: const TextStyle(
                          color: PassyTheme.lightContentSecondaryColor),
                    )
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
