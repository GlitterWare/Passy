import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/widgets/arrow_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/host_address.dart';
import 'package:passy/passy_data/loaded_account.dart';

import 'connect_screen.dart';
import 'log_screen.dart';
import 'passwords_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  static const routeName = '/main';

  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final LoadedAccount _account = data.loadedAccount!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Passy'),
        actions: [
          IconButton(
            splashRadius: appBarButtonSplashRadius,
            padding: appBarButtonPadding,
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: dialogShape,
                  title: Center(
                      child: Text(
                    'Synchronize',
                    style: TextStyle(color: lightContentColor),
                  )),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    TextButton(
                        child: Text(
                          'Host',
                          style: TextStyle(color: lightContentSecondaryColor),
                        ),
                        onPressed: () =>
                            SynchronizationWrapper(context: context)
                                .host(_account)),
                    TextButton(
                      child: Text(
                        'Connect',
                        style: TextStyle(color: lightContentSecondaryColor),
                      ),
                      onPressed: cameraSupported
                          ? () => FlutterBarcodeScanner.scanBarcode(
                                      '#9C27B0', 'Cancel', false, ScanMode.QR)
                                  .then((address) {
                                SynchronizationWrapper(context: context)
                                    .connect(_account, address: address);
                              })
                          : () {
                              Navigator.popUntil(
                                  context,
                                  (route) =>
                                      route.settings.name ==
                                      MainScreen.routeName);
                              Navigator.pushNamed(
                                  context, ConnectScreen.routeName,
                                  arguments: _account);
                            },
                    ),
                  ],
                ),
              ).then((value) => null);
            },
            icon: const Icon(Icons.sync_rounded),
          ),
          IconButton(
            padding: appBarButtonPadding,
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
            icon: const Icon(Icons.settings),
            splashRadius: appBarButtonSplashRadius,
          ),
        ],
      ),
      body: ListView(
        children: [
          ArrowButton(
            icon: const Icon(Icons.lock_rounded),
            body: const Align(
              child: Text('Passwords'),
              alignment: Alignment.centerLeft,
            ),
            onPressed: () {
              Navigator.pushNamed(context, PasswordsScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
