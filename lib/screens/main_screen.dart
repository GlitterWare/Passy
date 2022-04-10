import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:passy/widgets/entry_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/host_address.dart';
import 'package:passy/passy_data/loaded_account.dart';

import 'connect_screen.dart';
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
        title: const Text('Passy'),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Center(child: Text('Synchronize')),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        TextButton(
                          child: const Text('Host'),
                          onPressed: () =>
                              _account.host(context: context).then((value) {
                            if (value == null) return;
                            showDialog(
                              context: context,
                              builder: (_) => SimpleDialog(children: [
                                Center(
                                  child: SizedBox(
                                    width: 300,
                                    height: 350,
                                    child: Column(
                                      children: [
                                        QrImage(
                                          data: value.toString(),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(value.toString()),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            );
                          }),
                        ),
                        TextButton(
                          child: const Text('Connect'),
                          onPressed: cameraSupported
                              ? () => FlutterBarcodeScanner.scanBarcode(
                                          '#9C27B0',
                                          'Cancel',
                                          false,
                                          ScanMode.QR)
                                      .then((value) {
                                    try {
                                      _account.connect(HostAddress.parse(value),
                                          context: context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Row(children: const [
                                          Icon(Icons.sync_rounded,
                                              color: Colors.white),
                                          SizedBox(width: 20),
                                          Text('Connection failed'),
                                        ]),
                                      ));
                                    }
                                  })
                              : () => Navigator.pushReplacementNamed(
                                  context, ConnectScreen.routeName),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.sync_rounded),
                splashRadius: 20,
              ),
              IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, SettingsScreen.routeName),
                icon: const Icon(Icons.settings),
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          EntryButton(
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
