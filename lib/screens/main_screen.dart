import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:passy/common/common.dart';
import 'package:passy/common/synchronization_wrapper.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:universal_io/io.dart';

import 'payment_cards_screen.dart';
import 'connect_screen.dart';
import 'passwords_screen.dart';
import 'settings_screen.dart';
import 'id_cards_screen.dart';
import 'identities_screen.dart';
import 'notes_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  static const routeName = '/main';

  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final LoadedAccount _account = data.loadedAccount!;

  void _logOut() {
    data.unloadAccount();
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  Future<bool> _onWillPop() {
    _logOut();
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Passy'),
          leading: IconButton(
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            padding: PassyTheme.appBarButtonPadding,
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: _logOut,
          ),
          actions: [
            IconButton(
              splashRadius: PassyTheme.appBarButtonSplashRadius,
              padding: PassyTheme.appBarButtonPadding,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: PassyTheme.dialogShape,
                    title: const Center(
                        child: Text(
                      'Synchronize',
                      style: TextStyle(color: PassyTheme.lightContentColor),
                    )),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      TextButton(
                          child: const Text(
                            'Host',
                            style: TextStyle(
                                color: PassyTheme.lightContentSecondaryColor),
                          ),
                          onPressed: () =>
                              SynchronizationWrapper(context: context)
                                  .host(_account)),
                      TextButton(
                        child: const Text(
                          'Connect',
                          style: TextStyle(
                              color: PassyTheme.lightContentSecondaryColor),
                        ),
                        onPressed: Platform.isAndroid || Platform.isIOS
                            ? () => showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      title: const Text(
                                        'Scan QR code',
                                        textAlign: TextAlign.center,
                                      ),
                                      content: QRView(
                                        key: qrKey,
                                        onQRViewCreated: (controller) {
                                          bool _scanned = false;
                                          controller.scannedDataStream
                                              .listen((event) {
                                            if (_scanned) return;
                                            if (event.code == null) return;
                                            _scanned = true;
                                            SynchronizationWrapper(
                                                    context: context)
                                                .connect(_account,
                                                    address: event.code!);
                                          });
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.popUntil(
                                                context,
                                                (route) =>
                                                    route.settings.name ==
                                                    MainScreen.routeName);
                                            Navigator.pushNamed(context,
                                                ConnectScreen.routeName,
                                                arguments: _account);
                                          },
                                          child: const Text(
                                            'Can\'t scan?',
                                            style: TextStyle(
                                              color: PassyTheme
                                                  .lightContentSecondaryColor,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: PassyTheme
                                                  .lightContentSecondaryColor,
                                            ),
                                          ),
                                        )
                                      ],
                                    ))
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
              padding: PassyTheme.appBarButtonPadding,
              onPressed: () =>
                  Navigator.pushNamed(context, SettingsScreen.routeName),
              icon: const Icon(Icons.settings),
              splashRadius: PassyTheme.appBarButtonSplashRadius,
            ),
          ],
        ),
        body: ListView(
          children: [
            PassyPadding(ThreeWidgetButton(
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.lock_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              center: const Text('Passwords'),
              onPressed: () =>
                  Navigator.pushNamed(context, PasswordsScreen.routeName),
            )),
            PassyPadding(ThreeWidgetButton(
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.payment_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              center: const Text('Payment cards'),
              onPressed: () =>
                  Navigator.pushNamed(context, PaymentCardsScreen.routeName),
            )),
            PassyPadding(ThreeWidgetButton(
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.note_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              center: const Text('Notes'),
              onPressed: () =>
                  Navigator.pushNamed(context, NotesScreen.routeName),
            )),
            PassyPadding(ThreeWidgetButton(
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.perm_identity_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              center: const Text('ID Cards'),
              onPressed: () =>
                  Navigator.pushNamed(context, IDCardsScreen.routeName),
            )),
            PassyPadding(ThreeWidgetButton(
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.people_outline_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              center: const Text('Identities'),
              onPressed: () =>
                  Navigator.pushNamed(context, IdentitiesScreen.routeName),
            )),
          ],
        ),
      ),
    );
  }
}
