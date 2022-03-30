import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:otp/otp.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:passy/passy_data/host_address.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:passy/common/assets.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/screens/add_id_card_screen.dart';
import 'package:passy/screens/add_identity_screen.dart';
import 'package:passy/screens/add_password_screen.dart';
import 'package:passy/screens/add_payment_card_screen.dart';
import 'package:passy/screens/note_screen.dart';
import 'package:passy/screens/password_screen.dart';
import 'package:passy/screens/connect_screen.dart';
import 'package:passy/screens/settings_screen.dart';

//TODO: implement OTP display

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  static const routeName = '/main';

  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  String _title = 'Passwords';
  EntryType _tab = EntryType.password;
  final LoadedAccount _account = data.loadedAccount!;

  late TabController _controller;
  final List<Widget> _passwords = [];
  final List<Widget> _notes = [];
  final List<Widget> _paymentCards = [];
  final List<Widget> _idCards = [];
  final List<Widget> _identities = [];

  void _loadPasswords() {
    Widget _getIcon(String name) {
      Uint8List? _icon = _account.getPasswordIcon(name);
      if (_icon == null) {
        return SvgPicture.asset(
          logoCircleSvg,
          width: 50,
          color: Colors.purple,
        );
      }
      return Image.memory(_icon);
    }

    for (Password p in _account.passwords) {
      _passwords.add(Padding(
        padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, PasswordScreen.routeName,
                arguments: p);
          },
          child: Padding(
            child: Row(
              children: [
                Padding(
                  child: _getIcon(p.iconName),
                  padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                ),
                Flexible(
                  child: Column(
                    children: [
                      Align(
                        child: Text(
                          p.nickname,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      Align(
                        child: Text(
                          p.username,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                  fit: FlexFit.tight,
                ),
                const Icon(Icons.arrow_forward_ios_rounded)
              ],
            ),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          ),
          style: ElevatedButton.styleFrom(
              primary: Colors.white, onPrimary: Colors.black),
        ),
      ));
    }
  }

  void _loadNotes() {}

  void _loadPaymentCards() {}

  void _loadIDCards() {}

  void _loadIdentities() {}

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 5, vsync: this);
    _controller.addListener(() {
      switch (_controller.index) {
        case 0:
          _tab = EntryType.password;
          setState(() => _title = 'Passwords');
          break;
        case 1:
          _tab = EntryType.note;
          setState(() => _title = 'Notes');
          break;
        case 2:
          _tab = EntryType.paymentCard;
          setState(() => _title = 'Payment Cards');
          break;
        case 3:
          _tab = EntryType.idCard;
          setState(() => _title = 'ID Cards');
          break;
        case 4:
          _tab = EntryType.identity;
          setState(() => _title = 'Identities');
          break;
      }
    });

    _loadPasswords();
    _loadNotes();
    _loadPaymentCards();
    _loadIDCards();
    _loadIdentities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
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
                          onPressed: () => _account.host().then((value) {
                            if (value == null) return;
                            showDialog(
                              context: context,
                              builder: (_) => SimpleDialog(children: [
                                Center(
                                  child: SizedBox(
                                    width: 300,
                                    height: 300,
                                    child: QrImage(
                                      data: value.toString(),
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
                                      _account
                                          .connect(HostAddress.parse(value));
                                    } catch (e) {
                                      //TODO: show the popup context notification at the bottom of the screen
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
              IconButton(
                onPressed: () {
                  switch (_tab) {
                    case EntryType.password:
                      Navigator.pushNamed(context, AddPasswordScreen.routeName);
                      break;
                    case EntryType.paymentCard:
                      Navigator.pushNamed(
                          context, AddPaymentCardScreen.routeName);
                      break;
                    case EntryType.note:
                      Navigator.pushNamed(context, NoteScreen.routeName);
                      break;
                    case EntryType.idCard:
                      Navigator.pushNamed(context, AddIdCardScreen.routeName);
                      break;
                    case EntryType.identity:
                      Navigator.pushNamed(context, AddIdentityScreen.routeName);
                      break;
                  }
                },
                icon: const Icon(Icons.add_rounded),
                splashRadius: 20,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded),
                splashRadius: 20,
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(
              icon: Icon(Icons.lock),
            ),
            Tab(
                icon: Icon(
              Icons.sticky_note_2,
            )),
            Tab(icon: Icon(Icons.credit_card)),
            Tab(icon: Icon(Icons.co_present)),
            Tab(icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          _passwords.isEmpty
              ? const Center(child: Text('No passwords'))
              : ListView(
                  children: _passwords,
                  controller: ScrollController(),
                ),
          _notes.isEmpty
              ? const Center(child: Text('Widgets not implemented'))
              : ListView(
                  children: _notes,
                  controller: ScrollController(),
                ),
          _paymentCards.isEmpty
              ? const Center(child: Text('Widgets not implemented'))
              : ListView(
                  children: _paymentCards,
                  controller: ScrollController(),
                ),
          _idCards.isEmpty
              ? const Center(child: Text('Widgets not implemented'))
              : ListView(
                  children: _idCards,
                  controller: ScrollController(),
                ),
          _identities.isEmpty
              ? const Center(child: Text('Widgets not implemented'))
              : ListView(
                  children: _identities,
                  controller: ScrollController(),
                ),
        ],
      ),
    );
  }
}
