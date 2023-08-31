import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/interval_unit.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/manage_servers_screen.dart';
import 'package:passy/screens/settings_screen.dart';

import 'server_connect_screen.dart';
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
      //TODO: localize
      showSnackBar(context,
          message: 'Interval is less than 5 seconds',
          icon:
              const Icon(Icons.timelapse, color: PassyTheme.darkContentColor));
      return;
    }
    if (_syncIntervalUnits == IntervalUnit.seconds) {
      if (_syncInterval < 5) {
        //TODO: localize
        showSnackBar(context,
            message: 'Interval is less than 5 seconds',
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
        title: Text('Synchronization servers'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                PassyPadding(ThreeWidgetButton(
                    center: Text('Server setup'),
                    left: const Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Icon(Icons.install_desktop_rounded),
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () => Navigator.pushNamed(
                        context, ServerSetupScreen.routeName))),
                PassyPadding(ThreeWidgetButton(
                    center: Text('Connect to server'),
                    left: const Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Icon(Icons.cast_rounded),
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () => Navigator.pushNamed(
                            context, ServerConnectScreen.routeName)
                        .then((value) => setState(() {})))),
                if (_account.sync2d0d0ServerInfo.isNotEmpty)
                  PassyPadding(ThreeWidgetButton(
                      center: Text('Remove servers'),
                      left: const Padding(
                        padding: EdgeInsets.only(right: 30),
                        child: Icon(Icons.delete_rounded),
                      ),
                      right: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: () => Navigator.pushNamed(
                              context, ManageServersScreen.routeName)
                          .then((value) => setState(() {})))),
                PassyPadding(Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: TextFormField(
                        key: _syncIntervalKey,
                        initialValue: _syncIntervalString,
                        decoration: InputDecoration(
                            labelText: 'Synchronization interval'),
                        onChanged: (value) =>
                            setState(() => _syncIntervalString = value),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    Flexible(
                      child: EnumDropDownButtonFormField<IntervalUnit>(
                        value: _syncIntervalUnits,
                        values: IntervalUnit.values,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _syncIntervalUnits = value);
                        },
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: null,
                      child: Icon(Icons.close),
                      onPressed: _resetSyncIntervalUnits,
                      //TODO: localize
                      tooltip: 'Reset',
                    ),
                    FloatingActionButton(
                      heroTag: null,
                      child: Icon(Icons.save),
                      onPressed: _saveSyncIntervalUnits,
                      //TODO: localize
                      tooltip: 'Save',
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
