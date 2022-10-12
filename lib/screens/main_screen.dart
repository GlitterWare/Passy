import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_screen/flutter_secure_screen.dart';
import 'package:image/image.dart' as imglib;
import 'package:passy/screens/common.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/unlock_screen.dart';

import 'package:passy/common/common.dart';
import 'package:passy/common/synchronization_wrapper.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:zxing2/zxing2.dart';

import 'payment_cards_screen.dart';
import 'connect_screen.dart';
import 'passwords_screen.dart';
import 'settings_screen.dart';
import 'id_cards_screen.dart';
import 'identities_screen.dart';
import 'notes_screen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  static bool shouldLockScreen = true;

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final LoadedAccount _account = data.loadedAccount!;
  late void Function() _onConnectPressed;
  bool _unlockScreenOn = false;

  void _logOut() {
    data.unloadAccount();
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  Future<bool> _onWillPop() {
    _logOut();
    return Future.value(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!MainScreen.shouldLockScreen) return;
    if (_unlockScreenOn) return;
    _unlockScreenOn = true;
    Navigator.pushNamed(context, UnlockScreen.routeName)
        .then((value) => _unlockScreenOn = false);
  }

  @override
  Future<bool> didPushRoute(String route) {
    if (route == UnlockScreen.routeName) _unlockScreenOn = true;
    return Future.value(true);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
  }

  Future<void> _showConnectDialog() async {
    CameraController _controller = CameraController(
      (await availableCameras()).first,
      ResolutionPreset.low,
      enableAudio: false,
    );
    Future<void> _initializeControllerFuture = _controller.initialize();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text(
                'Scan QR code',
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                width: 250,
                height: 250,
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(_controller);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context,
                        (route) => route.settings.name == MainScreen.routeName);
                    Navigator.pushNamed(context, ConnectScreen.routeName,
                        arguments: _account);
                  },
                  child: const Text(
                    'Can\'t scan?',
                    style: TextStyle(
                      color: PassyTheme.lightContentSecondaryColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: PassyTheme.lightContentSecondaryColor,
                    ),
                  ),
                )
              ],
            )).whenComplete(() {
      _controller.dispose();
    });
    Future(() async {
      await _initializeControllerFuture;
      _controller.startImageStream((image) {
        imglib.Image? _image = imageFromCameraImage(image);
        if (_image == null) return;
        Result? _result = qrResultFromImage(_image);
        if (_result == null) {
          _result = qrResultFromImage(imglib.invert(_image));
          if (_result == null) {
            return;
          }
        }
        Navigator.popUntil(
            context, (route) => route.settings.name == MainScreen.routeName);
        SynchronizationWrapper(context: context)
            .connect(_account, address: _result.text);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    FlutterSecureScreen.singleton
        .setAndroidScreenSecure(_account.protectScreen);
    WidgetsBinding.instance.addObserver(this);
    _onConnectPressed = Platform.isAndroid || Platform.isIOS
        ? _showConnectDialog
        : () {
            Navigator.popUntil(context,
                (route) => route.settings.name == MainScreen.routeName);
            Navigator.pushNamed(context, ConnectScreen.routeName,
                arguments: _account);
          };
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
                        onPressed: _onConnectPressed,
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
                child: Icon(Icons.password_rounded),
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
              center: const Text('ID cards'),
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
