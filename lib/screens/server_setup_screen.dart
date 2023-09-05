import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/log_screen.dart';
import 'package:passy/screens/servers_screen.dart';

class ServerSetupScreen extends StatefulWidget {
  const ServerSetupScreen({Key? key}) : super(key: key);

  static const routeName = '${ServersScreen.routeName}/setup';

  @override
  State<StatefulWidget> createState() => _ServerSetupScreen();
}

class _ServerSetupScreen extends State<ServerSetupScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  String? _address;
  int _port = 5592;
  bool _connectionChecked = false;

  Future<void> _onInstallPressed() async {
    String? address = _address;
    if (address == null) {
      showSnackBar(
        context,
        message: localizations.hostAddressIsEmpty,
        icon: const Icon(Icons.desktop_windows_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    if (address.isEmpty) {
      showSnackBar(
        context,
        message: localizations.hostAddressIsEmpty,
        icon: const Icon(Icons.desktop_windows_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    if (_port == 0) {
      showSnackBar(
        context,
        message: localizations.invalidPortSpecified,
        icon: const Icon(Icons.numbers_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    String? dirResult;
    try {
      dirResult = await FilePicker.platform.getDirectoryPath(
        dialogTitle: localizations.installServer,
        lockParentWindow: true,
      );
      if (dirResult == null) return;
      await copyPassyCLIServer(
        from: File(Platform.resolvedExecutable).parent,
        to: Directory(dirResult + Platform.pathSeparator + 'Passy-CLI-Server'),
        address: address,
        port: _port,
      );
      showSnackBar(
        context,
        message: localizations.serverInstalled,
        icon: const Icon(Icons.install_desktop_rounded,
            color: PassyTheme.darkContentColor),
      );
    } catch (e, s) {
      showSnackBar(
        context,
        message: localizations.couldNotInstallServer,
        icon: const Icon(Icons.install_desktop_rounded,
            color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
      return;
    }
  }

  Future<void> _onCheckPressed() async {
    String? address = _address;
    if (address == null) {
      showSnackBar(
        context,
        message: localizations.hostAddressIsEmpty,
        icon: const Icon(Icons.desktop_windows_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    if (address.isEmpty) {
      showSnackBar(
        context,
        message: localizations.hostAddressIsEmpty,
        icon: const Icon(Icons.desktop_windows_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    if (_port == 0) {
      showSnackBar(
        context,
        message: localizations.invalidPortSpecified,
        icon: const Icon(Icons.numbers_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    try {
      await _account.testSynchronizationConnection2d0d0(address, _port);
    } catch (e, s) {
      showSnackBar(
        context,
        message: localizations.couldNotConnectToServer,
        icon: const Icon(
          Icons.cast_rounded,
          color: PassyTheme.darkContentColor,
        ),
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
        title: Text(localizations.synchronizationServerSetup),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: _address == null
                  ? const [
                      Spacer(),
                      Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: PassyTheme.lightContentColor,
                          ),
                        ),
                      ),
                      Spacer(),
                    ]
                  : [
                      PassyPadding(Text(
                        localizations.syncServerSetupInfo,
                        textAlign: TextAlign.center,
                      )),
                      PassyPadding(
                        Text.rich(
                          TextSpan(
                            text: '1. ',
                            children: [
                              TextSpan(
                                text:
                                    '${localizations.chooseHostAddressAndPort}:',
                                style: const TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
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
                                  left: PassyTheme.passyPadding.right,
                                  top: PassyTheme.passyPadding.top,
                                  bottom: PassyTheme.passyPadding.bottom),
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
                                  left: PassyTheme.passyPadding.right,
                                  top: PassyTheme.passyPadding.top,
                                  bottom: PassyTheme.passyPadding.bottom),
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
                                text: '${localizations.installServer}:',
                                style: const TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      PassyPadding(ThreeWidgetButton(
                          center: Text(localizations.installServer),
                          left: const Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Icon(Icons.install_desktop_rounded),
                          ),
                          right: const Icon(Icons.arrow_forward_ios_rounded),
                          onPressed: _onInstallPressed)),
                      PassyPadding(
                        Text.rich(
                          TextSpan(
                            text: '3. ',
                            children: [
                              TextSpan(
                                text: '${localizations.startServer}:',
                                style: const TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: localizations.doubleClickMessage,
                          children: [
                            TextSpan(
                              text: 'passy_cli' +
                                  (Platform.isWindows ? '.exe' : ''),
                              style: const TextStyle(
                                  color: PassyTheme.lightContentSecondaryColor),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(localizations.doubleClickMessage1),
                      PassyPadding(
                        Text.rich(
                          TextSpan(
                            text: '4. ',
                            children: [
                              TextSpan(
                                text: '${localizations.testConnection}:',
                                style: const TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
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
                                  onPressed: () => _onCheckPressed()))),
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
                            text: '5. (${localizations.optional}) ',
                            children: [
                              TextSpan(
                                text: '${localizations.addServerToAutostart}:',
                                style: const TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: localizations.doubleClickMessage,
                          children: [
                            TextSpan(
                              text: 'autostart_add' +
                                  (Platform.isWindows ? '.bat' : '.sh'),
                              style: const TextStyle(
                                  color: PassyTheme.lightContentSecondaryColor),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(localizations.doubleClickMessage1),
                      PassyPadding(
                        Text.rich(
                          TextSpan(
                            text: '6. ',
                            children: [
                              TextSpan(
                                text: '${localizations.connectToServer}:',
                                style: const TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      PassyPadding(
                        Text.rich(
                          TextSpan(
                            text: '${localizations.onClientDevices}: ',
                            children: [
                              const WidgetSpan(
                                  child: Icon(
                                Icons.settings_rounded,
                                size: 14,
                                color: PassyTheme.lightContentSecondaryColor,
                              )),
                              TextSpan(
                                text: ' ${localizations.settings} ',
                                style: const TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                              const WidgetSpan(
                                  child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                              )),
                              const TextSpan(text: '  '),
                              const WidgetSpan(
                                  child: Icon(
                                Icons.desktop_windows_rounded,
                                size: 14,
                                color: PassyTheme.lightContentSecondaryColor,
                              )),
                              TextSpan(
                                text:
                                    ' ${localizations.synchronizationServers} ',
                                style: const TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                              const WidgetSpan(
                                  child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                              )),
                              const TextSpan(text: '  '),
                              const WidgetSpan(
                                  child: Icon(
                                Icons.cast,
                                size: 14,
                                color: PassyTheme.lightContentSecondaryColor,
                              )),
                              TextSpan(
                                text: ' ${localizations.connectToServer} ',
                                style: const TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
