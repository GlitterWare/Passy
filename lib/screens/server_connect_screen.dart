import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/main.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/sync_2d0d0_server_info.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/log_screen.dart';
import 'package:passy/screens/servers_screen.dart';

class ServerConnectScreen extends StatefulWidget {
  const ServerConnectScreen({Key? key}) : super(key: key);

  static const routeName = '${ServersScreen.routeName}/connect';

  @override
  State<StatefulWidget> createState() => _ServerConnectScreen();
}

class _ServerConnectScreen extends State<ServerConnectScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  String? _address;
  int _port = 5592;
  bool _connectionChecked = false;
  String _nickname = 'Home server';

  Future<void> _onConnectPressed({bool testRun = false}) async {
    if (!testRun) {
      if (_nickname.isEmpty) {
        showSnackBar(
          message: localizations.nicknameCanNotBeEmpty,
          icon: const Icon(Icons.desktop_windows_rounded),
        );
        return;
      }
      if (_account.sync2d0d0ServerInfo.keys.contains(_nickname)) {
        showSnackBar(
            message: localizations.nicknameAlreadyInUse,
            icon: const Icon(Icons.desktop_windows_rounded));
        return;
      }
    }
    String? address = _address;
    if (address == null) {
      showSnackBar(
        message: localizations.hostAddressIsEmpty,
        icon: const Icon(Icons.desktop_windows_rounded),
      );
      return;
    }
    if (address.isEmpty) {
      showSnackBar(
        message: localizations.hostAddressIsEmpty,
        icon: const Icon(Icons.desktop_windows_rounded),
      );
      return;
    }
    if (_port == 0) {
      showSnackBar(
        message: localizations.invalidPortSpecified,
        icon: const Icon(Icons.numbers_rounded),
      );
      return;
    }
    try {
      await _account.testSynchronizationConnection2d0d0(address, _port);
    } catch (e, s) {
      showSnackBar(
        message: localizations.couldNotConnectToServer,
        icon: const Icon(Icons.cast_rounded),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
      setState(() => _connectionChecked = false);
      return;
    }
    setState(() => _connectionChecked = true);
    if (testRun) return;
    showSnackBar(
      message: localizations.connecting,
      icon: const Icon(Icons.cast_rounded),
    );
    try {
      await _account.trustServer(Sync2d0d0ServerInfo(
          nickname: _nickname, address: address, port: _port));
    } catch (e, s) {
      if (navigatorKey.currentContext == null) return;
      showSnackBar(
        message: localizations.couldNotConnectToServer,
        icon: const Icon(Icons.cast_rounded),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
      return;
    }
    _account.addSync2d0d0ServerInfo([
      Sync2d0d0ServerInfo(nickname: _nickname, address: address, port: _port)
    ]);
    await _account.saveSettings();
    if (navigatorKey.currentContext == null) return;
    showSnackBar(
      message: localizations.connectionEstablished,
      icon: const Icon(Icons.cast_rounded),
    );
  }

  @override
  void initState() {
    super.initState();
    getInternetAddress().then((value) => setState(() => _address = value));
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
        title: Text(localizations.connectToSynchronizationServer),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: _address == null
                  ? [
                      const Spacer(),
                      Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: PassyTheme.of(context).contentTextColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ]
                  : [
                      PassyPadding(
                        Text.rich(
                          TextSpan(
                            text: '1. ',
                            children: [
                              TextSpan(
                                text: localizations.chooseHostAddressAndPort,
                                style: TextStyle(
                                    color: PassyTheme.of(context)
                                        .highlightContentSecondaryColor),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      PassyTheme.of(context).passyPadding.right,
                                  top: PassyTheme.of(context).passyPadding.top,
                                  bottom: PassyTheme.of(context)
                                      .passyPadding
                                      .bottom),
                              child: TextFormField(
                                initialValue: _address,
                                decoration: InputDecoration(
                                  labelText: localizations.hostAddress,
                                ),
                                onChanged: (s) => setState(() => _address = s),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      PassyTheme.of(context).passyPadding.right,
                                  top: PassyTheme.of(context).passyPadding.top,
                                  bottom: PassyTheme.of(context)
                                      .passyPadding
                                      .bottom),
                              child: TextFormField(
                                initialValue: _port.toString(),
                                decoration: InputDecoration(
                                  labelText: localizations.port,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (s) {
                                  setState(() =>
                                      _port = s.isEmpty ? 0 : int.parse(s));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      PassyPadding(
                        Text.rich(
                          TextSpan(
                            text: '2. ',
                            children: [
                              TextSpan(
                                text: localizations.testConnection,
                                style: TextStyle(
                                    color: PassyTheme.of(context)
                                        .highlightContentSecondaryColor),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                              child: PassyPadding(ThreeWidgetButton(
                                  center: Text(localizations.testConnection),
                                  left: const Padding(
                                    padding: EdgeInsets.only(right: 30),
                                    child: Icon(Icons.cast_rounded),
                                  ),
                                  right: const Icon(
                                      Icons.arrow_forward_ios_rounded),
                                  onPressed: () =>
                                      _onConnectPressed(testRun: true)))),
                          if (!_connectionChecked)
                            const Flexible(
                                child: PassyPadding(Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 35,
                            ))),
                          if (_connectionChecked)
                            const Flexible(
                                child: PassyPadding(Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 35,
                            ))),
                        ],
                      ),
                      PassyPadding(
                        Text.rich(
                          TextSpan(
                            text: '3. ',
                            children: [
                              TextSpan(
                                text: localizations.connectToServer,
                                style: TextStyle(
                                    color: PassyTheme.of(context)
                                        .highlightContentSecondaryColor),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      PassyPadding(TextFormField(
                        initialValue: _nickname,
                        decoration: InputDecoration(
                          labelText: localizations.nickname,
                        ),
                        onChanged: (value) => setState(() => _nickname = value),
                      )),
                      PassyPadding(ThreeWidgetButton(
                          center: Text(localizations.connectToServer),
                          left: const Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Icon(Icons.cast_rounded),
                          ),
                          right: const Icon(Icons.arrow_forward_ios_rounded),
                          onPressed: () => _onConnectPressed())),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
