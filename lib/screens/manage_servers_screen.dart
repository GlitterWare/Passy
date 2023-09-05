import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'servers_screen.dart';

class ManageServersScreen extends StatefulWidget {
  const ManageServersScreen({Key? key}) : super(key: key);

  static const routeName = '${ServersScreen.routeName}/manage';

  @override
  State<StatefulWidget> createState() => _ManageServersScreen();
}

class _ManageServersScreen extends State<ManageServersScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  List<Widget> _servers = [];

  List<Widget> _buildServers() {
    List<Widget> result = [];
    List<String> serverNicknames = _account.sync2d0d0ServerInfo.keys.toList();
    for (String nickname in serverNicknames) {
      Widget widget = PassyPadding(ThreeWidgetButton(
          center: Text('${localizations.remove} $nickname'),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.delete_rounded),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () async {
            _account.removeSync2d0d0ServerInfo(nickname);
            await _account.saveSettings();
            if (_account.sync2d0d0ServerInfo.isEmpty) {
              Navigator.pop(context);
            } else {
              setState(() => _servers = _buildServers());
            }
          }));
      result.add(widget);
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _servers = _buildServers();
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
              children: _servers,
            ),
          ),
        ],
      ),
    );
  }
}
