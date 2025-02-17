import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/auto_backup_settings.dart';
import 'package:passy/passy_data/interval_unit.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/screens/unlock_screen.dart';

import 'common.dart';
import 'confirm_restore_screen.dart';
import 'settings_screen.dart';

class BackupAndRestoreScreen extends StatefulWidget {
  const BackupAndRestoreScreen({Key? key}) : super(key: key);

  static const routeName = '${SettingsScreen.routeName}/backupAndRestore';

  @override
  State<StatefulWidget> createState() => _BackupAndRestoreScreen();
}

class _BackupAndRestoreScreen extends State<BackupAndRestoreScreen> {
  final _account = data.loadedAccount!;
  int _buInterval = 1;
  IntervalUnit _buIntervalUnits = IntervalUnit.weeks;

  Future<void> _onBackupPressed(String username) async {
    try {
      await backupAccount(context, username: username, autoFilename: false);
    } catch (e) {
      return;
    }
  }

  void _onRestorePressed() {
    UnlockScreen.shouldLockScreen = false;
    FilePicker.platform
        .pickFiles(
      dialogTitle: localizations.restorePassyBackup,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      lockParentWindow: true,
    )
        .then(
      (_pick) {
        Future.delayed(const Duration(seconds: 2))
            .then((value) => UnlockScreen.shouldLockScreen = true);
        if (_pick == null) return;
        Navigator.pushNamed(
          context,
          ConfirmRestoreScreen.routeName,
          arguments: _pick.files[0].path,
        );
      },
    );
  }

  Future<void> _onBuIntervalChanged(String value) async {
    if (value == '') return;
    setState(() => _buInterval = int.parse(value));
    int _val = _buInterval;
    _val = IntervalUnitsInMilliseconds.toMilliseconds(
        value: _val, unit: _buIntervalUnits);
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
    final String _username =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.backupAndRestore),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.backup),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.ios_share_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => _onBackupPressed(_username),
          )),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.restore),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.settings_backup_restore_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => _onRestorePressed(),
          )),
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
              Text.rich(
                TextSpan(
                  text: localizations.backupPathColon,
                  children: [
                    TextSpan(
                      text: _account.autoBackup!.path,
                      style: TextStyle(
                          color: PassyTheme.of(context)
                              .highlightContentSecondaryColor),
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
