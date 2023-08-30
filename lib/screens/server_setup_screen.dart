import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/glare/glare_client.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/log_screen.dart';

class ServerSetupScreen extends StatefulWidget {
  const ServerSetupScreen({Key? key}) : super(key: key);

  //TODO: placeholder routename, change once dedicated server screen is implemented
  static const routeName = '/serverSetup';

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
        message: 'Host address is empty',
        icon: const Icon(Icons.desktop_windows_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    if (address.isEmpty) {
      showSnackBar(
        context,
        message: 'Host address is empty',
        icon: const Icon(Icons.desktop_windows_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    if (_port == 0) {
      showSnackBar(
        context,
        message: 'Invalid port specified',
        icon: const Icon(Icons.numbers_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    String? dirResult;
    try {
      dirResult = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Install server',
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
        message: "Server installed",
        icon: const Icon(Icons.install_desktop_rounded,
            color: PassyTheme.darkContentColor),
      );
    } catch (e, s) {
      showSnackBar(
        context,
        message: "Could not install server",
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
        message: 'Host address is empty',
        icon: const Icon(Icons.desktop_windows_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    if (address.isEmpty) {
      showSnackBar(
        context,
        message: 'Host address is empty',
        icon: const Icon(Icons.desktop_windows_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    if (_port == 0) {
      showSnackBar(
        context,
        message: 'Invalid port specified',
        icon: const Icon(Icons.numbers_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    GlareClient? client;
    try {
      client = await connectTo2d0d0Server(address, _port);
    } catch (e, s) {
      showSnackBar(
        context,
        message: "Could not connect to server",
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
    try {
      await client.disconnect();
    } catch (_) {}
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
        title: Text('Synchronization server setup'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
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
                      PassyPadding(
                        RichText(
                          textScaleFactor: 1.25,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '1. ',
                            children: [
                              TextSpan(
                                text: 'Choose host address and port:',
                                style: TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: Row(
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
                                  onChanged: (s) =>
                                      setState(() => _address = s),
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
                                    labelText: 'Port',
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
                      ),
                      PassyPadding(
                        RichText(
                          textScaleFactor: 1.25,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '2. ',
                            children: [
                              TextSpan(
                                text: 'Install server:',
                                style: TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PassyPadding(ThreeWidgetButton(
                          center: Text('Install server'),
                          left: const Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Icon(Icons.install_desktop_rounded),
                          ),
                          right: const Icon(Icons.arrow_forward_ios_rounded),
                          onPressed: _onInstallPressed)),
                      PassyPadding(
                        RichText(
                          textScaleFactor: 1.25,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '3. ',
                            children: [
                              TextSpan(
                                text: 'Start server:',
                                style: TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      RichText(
                        textScaleFactor: 1.25,
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text:
                              'Navigate to the specified install directory in your file manager and double-click ',
                          children: [
                            TextSpan(
                              text: 'passy_cli' +
                                  (Platform.isWindows ? '.exe' : ''),
                              style: TextStyle(
                                  color: PassyTheme.lightContentSecondaryColor),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      PassyPadding(
                        RichText(
                          textScaleFactor: 1.25,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '4. ',
                            children: [
                              TextSpan(
                                text: 'Check connection:',
                                style: TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                              child: PassyPadding(ThreeWidgetButton(
                                  center: Text('Check connection'),
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
                        RichText(
                          textScaleFactor: 1.25,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '5. (Optional) ',
                            children: [
                              TextSpan(
                                text: 'Add server to autostart:',
                                style: TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      RichText(
                        textScaleFactor: 1.25,
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text:
                              'Navigate to the specified install directory in your file manager and double-click ',
                          children: [
                            TextSpan(
                              text: 'autostart_add' +
                                  (Platform.isWindows ? '.bat' : ''),
                              style: TextStyle(
                                  color: PassyTheme.lightContentSecondaryColor),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      PassyPadding(
                        RichText(
                          textScaleFactor: 1.25,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '6. ',
                            children: [
                              TextSpan(
                                text: 'Connect to server:',
                                style: TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PassyPadding(
                        RichText(
                          textScaleFactor: 1.25,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'On client device: ',
                            children: [
                              WidgetSpan(
                                  child: Icon(
                                Icons.settings_rounded,
                                size: 14,
                                color: PassyTheme.lightContentSecondaryColor,
                              )),
                              TextSpan(
                                text: ' Settings ',
                                style: TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                              WidgetSpan(
                                  child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                              )),
                              TextSpan(text: '  '),
                              WidgetSpan(
                                  child: Icon(
                                Icons.desktop_windows_rounded,
                                size: 14,
                                color: PassyTheme.lightContentSecondaryColor,
                              )),
                              TextSpan(
                                text: ' Synchronization servers ',
                                style: TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                              WidgetSpan(
                                  child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                              )),
                              TextSpan(text: '  '),
                              WidgetSpan(
                                  child: Icon(
                                Icons.cast,
                                size: 14,
                                color: PassyTheme.lightContentSecondaryColor,
                              )),
                              TextSpan(
                                text: ' Connect to server ',
                                style: TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                            ],
                          ),
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
