import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/interval_unit.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/manage_servers_screen.dart';
import 'package:passy/screens/settings_screen.dart';
import 'package:text_divider/text_divider.dart';

import 'server_connect_screen.dart';
import 'synchronization_logs_screen.dart';
import 'server_setup_screen.dart';

class ServersScreen extends StatefulWidget {
  const ServersScreen({Key? key}) : super(key: key);

  static const routeName = '${SettingsScreen.routeName}/servers';

  @override
  State<StatefulWidget> createState() => _ServersScreen();
}

class _ServersScreen extends State<ServersScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  int _syncInterval = 15;
  String _syncIntervalString = '';
  UniqueKey _syncIntervalKey = UniqueKey();
  IntervalUnit _syncIntervalUnits = IntervalUnit.seconds;

  void _loadSyncIntervalUnits() {
    int _intervalMs = _account.serverSyncInterval;
    bool _setInterval(IntervalUnit unit) {
      double _interval =
          _intervalMs.toDouble() / IntervalUnitsInMilliseconds.getByUnit(unit);
      int _intervalInt = _interval.toInt();
      if (_intervalInt != _interval) return false;
      _syncIntervalUnits = unit;
      _syncInterval = _intervalInt;
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

  void _resetSyncIntervalUnits() {
    _loadSyncIntervalUnits();
    setState(() {
      _syncIntervalString = _syncInterval.toString();
      _syncIntervalKey = UniqueKey();
    });
  }

  Future<void> _saveSyncIntervalUnits() async {
    if (_syncIntervalString == '') {
      _syncInterval = 0;
    } else {
      _syncInterval = int.parse(_syncIntervalString);
    }
    if (_syncInterval < 1) {
      showSnackBar(
          message:
              '${localizations.intervalIsLessThan}5 ${localizations.seconds.toLowerCase()}',
          icon:
              const Icon(Icons.timelapse, color: PassyTheme.darkContentColor));
      return;
    }
    if (_syncIntervalUnits == IntervalUnit.seconds) {
      if (_syncInterval < 5) {
        showSnackBar(
            message:
                '${localizations.intervalIsLessThan}5 ${localizations.seconds.toLowerCase()}',
            icon: const Icon(Icons.timelapse,
                color: PassyTheme.darkContentColor));
        return;
      }
    }
    setState(() {
      _account.serverSyncInterval = IntervalUnitsInMilliseconds.toMilliseconds(
          value: _syncInterval, unit: _syncIntervalUnits);
    });
    await _account.save();
  }

  @override
  void initState() {
    super.initState();
    _loadSyncIntervalUnits();
    _syncIntervalString = _syncInterval.toString();
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
        title: Text(localizations.synchronizationServers),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                if (!Platform.isAndroid && !Platform.isIOS)
                  PassyPadding(ThreeWidgetButton(
                      center: Text(localizations.serverSetup),
                      left: const Padding(
                        padding: EdgeInsets.only(right: 30),
                        child: Icon(Icons.install_desktop_rounded),
                      ),
                      right: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: () => Navigator.pushNamed(
                          context, ServerSetupScreen.routeName))),
                PassyPadding(ThreeWidgetButton(
                    center: Text(localizations.connectToServer),
                    left: const Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Icon(Icons.cast_rounded),
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () => Navigator.pushNamed(
                            context, ServerConnectScreen.routeName)
                        .then((value) => setState(() {})))),
                PassyPadding(ThreeWidgetButton(
                    center: Text(localizations.synchronizationLogs),
                    left: const Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Icon(Icons.error_outline),
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () => Navigator.pushNamed(
                            context, SynchronizationLogsScreen.routeName)
                        .then((value) => setState(() {})))),
                if (_account.sync2d0d0ServerInfo.isNotEmpty)
                  PassyPadding(ThreeWidgetButton(
                      center: Text(localizations.removeServers),
                      left: const Padding(
                        padding: EdgeInsets.only(right: 30),
                        child: Icon(Icons.delete_outline_rounded),
                      ),
                      right: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: () => Navigator.pushNamed(
                              context, ManageServersScreen.routeName)
                          .then((value) => setState(() {})))),
                TextDivider.horizontal(
                  color: PassyTheme.lightContentSecondaryColor,
                  text: Text(
                    localizations.synchronizationInterval,
                    style: const TextStyle(
                        color: PassyTheme.lightContentSecondaryColor),
                  ),
                ),
                PassyPadding(Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: TextFormField(
                        key: _syncIntervalKey,
                        initialValue: _syncIntervalString,
                        onChanged: (value) =>
                            setState(() => _syncIntervalString = value),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: EnumDropDownButtonFormField<IntervalUnit>(
                        value: _syncIntervalUnits,
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
                          setState(() => _syncIntervalUnits = value);
                        },
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: null,
                      child: const Icon(Icons.close),
                      onPressed: _resetSyncIntervalUnits,
                      tooltip: localizations.reset,
                    ),
                    FloatingActionButton(
                      heroTag: null,
                      child: const Icon(Icons.save),
                      onPressed: _saveSyncIntervalUnits,
                      tooltip: localizations.save,
                    ),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
