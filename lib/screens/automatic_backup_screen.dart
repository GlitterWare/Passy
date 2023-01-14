import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/auto_backup_settings.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'common.dart';
import 'settings_screen.dart';

class AutomaticBackupScreen extends StatefulWidget {
  static const routeName = '${SettingsScreen.routeName}/autoBackup';

  const AutomaticBackupScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutomaticBackupScreen();
}

enum _BackupIntervalUnit {
  years,
  months,
  weeks,
  days,
  hours,
  minutes,
  seconds,
}

abstract class _BackupIntervalUnitsInMilliseconds {
  static const int year = 31556952000;
  static const int month = 2629746000;
  static const int week = 604800000;
  static const int day = 86400000;
  static const int hour = 3600000;
  static const int minute = 60000;
  static const int second = 1000;

  static int getByUnit(_BackupIntervalUnit unit) {
    switch (unit) {
      case _BackupIntervalUnit.years:
        return year;
      case _BackupIntervalUnit.months:
        return month;
      case _BackupIntervalUnit.weeks:
        return week;
      case _BackupIntervalUnit.days:
        return day;
      case _BackupIntervalUnit.hours:
        return hour;
      case _BackupIntervalUnit.minutes:
        return minute;
      case _BackupIntervalUnit.seconds:
        return second;
    }
  }
}

class _AutomaticBackupScreen extends State<AutomaticBackupScreen> {
  final _account = data.loadedAccount!;
  int _buInterval = 1;
  _BackupIntervalUnit _buIntervalUnits = _BackupIntervalUnit.weeks;

  Future<void> _onBuIntervalChanged(String value) async {
    if (value == '') return;
    setState(() => _buInterval = int.parse(value));
    int _val = _buInterval;
    switch (_buIntervalUnits) {
      case _BackupIntervalUnit.years:
        _val = _val * _BackupIntervalUnitsInMilliseconds.year;
        break;
      case _BackupIntervalUnit.months:
        _val = _val * _BackupIntervalUnitsInMilliseconds.month;
        break;
      case _BackupIntervalUnit.weeks:
        _val = _val * _BackupIntervalUnitsInMilliseconds.week;
        break;
      case _BackupIntervalUnit.days:
        _val = _val * _BackupIntervalUnitsInMilliseconds.day;
        break;
      case _BackupIntervalUnit.hours:
        _val = _val * _BackupIntervalUnitsInMilliseconds.hour;
        break;
      case _BackupIntervalUnit.minutes:
        _val = _val * _BackupIntervalUnitsInMilliseconds.minute;
        break;
      case _BackupIntervalUnit.seconds:
        _val = _val * _BackupIntervalUnitsInMilliseconds.second;
        break;
    }
    _account.autoBackup!.lastBackup = DateTime.now().toUtc();
    _account.autoBackup!.backupInterval = _val;
    await _account.saveLocalSettings();
    data.refreshAccounts();
  }

  Future<void> _onBuIntervalUnitsChanged(_BackupIntervalUnit? value) async {
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
    bool _setInterval(_BackupIntervalUnit unit) {
      double _interval = _intervalMs.toDouble() /
          _BackupIntervalUnitsInMilliseconds.getByUnit(unit);
      int _intervalInt = _interval.toInt();
      if (_intervalInt != _interval) return false;
      _buIntervalUnits = unit;
      _buInterval = _intervalInt;
      return true;
    }

    if (_setInterval(_BackupIntervalUnit.years)) return;
    if (_setInterval(_BackupIntervalUnit.months)) return;
    if (_setInterval(_BackupIntervalUnit.weeks)) return;
    if (_setInterval(_BackupIntervalUnit.days)) return;
    if (_setInterval(_BackupIntervalUnit.hours)) return;
    if (_setInterval(_BackupIntervalUnit.minutes)) return;
    if (_setInterval(_BackupIntervalUnit.seconds)) return;
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
        title: const Text('Automatic Backup'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: const Text('Automatic backup'),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.save_outlined),
            ),
            right: Switch(
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
                    decoration: const InputDecoration(labelText: 'Interval'),
                    initialValue: _buInterval.toString(),
                    onChanged: _onBuIntervalChanged,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      FilteringTextInputFormatter.deny(RegExp('^0')),
                    ],
                  ),
                ),
                Flexible(
                  child: EnumDropDownButtonFormField<_BackupIntervalUnit>(
                    value: _buIntervalUnits,
                    values: _BackupIntervalUnit.values,
                    onChanged: _onBuIntervalUnitsChanged,
                  ),
                )
              ],
            )),
          if (_account.autoBackup != null)
            PassyPadding(ThreeWidgetButton(
              center: const Text('Change backup path'),
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
                  text: 'Backup path: ',
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
