import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/log_screen.dart';

import 'servers_screen.dart';

class SynchronizationLogsScreen extends StatefulWidget {
  const SynchronizationLogsScreen({Key? key}) : super(key: key);

  static const routeName = '${ServersScreen.routeName}/logs';

  @override
  State<StatefulWidget> createState() => _SynchronizationLogsScreen();
}

class _SynchronizationLogsScreen extends State<SynchronizationLogsScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  List<Widget> _servers = [];

  List<Widget> _buildLogs() {
    List<Widget> result;
    Map<DateTime, String> logs = _account.synchronizationLogs;
    if (logs.isEmpty) {
      result = [
        const Spacer(),
        Text.rich(
          TextSpan(
            children: [
              const WidgetSpan(
                  child: Icon(
                Icons.hourglass_empty,
                size: 18,
              )),
              TextSpan(text: localizations.noRecentActivity),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
      ];
      return result;
    }
    result = [];
    for (MapEntry<DateTime, String> log in logs.entries.toList().reversed) {
      DateTime date = log.key.toUtc();
      Widget widget = PassyPadding(ThreeWidgetButton(
          center: Text(
              '${date.hour < 10 ? '0' : ''}${date.hour}:${date.minute < 10 ? '0' : ''}${date.minute}:${date.second < 10 ? '0' : ''}${date.second} | ${date.day < 10 ? '0' : ''}${date.day}/${date.month < 10 ? '0' : ''}${date.month}/${date.year}'),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.error_outline),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: log.value)));
      result.add(widget);
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _servers = _buildLogs();
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
        title: Text(localizations.synchronizationLogs),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: _servers,
            ),
          ),
        ],
      ),
    );
  }
}
