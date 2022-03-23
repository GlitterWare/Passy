import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/common/state.dart';
import 'package:passy/passy/common.dart';
import 'package:passy/passy/loaded_account.dart';
import 'package:otp/otp.dart';
import 'package:passy/passy/password.dart';
import 'package:passy/screens/add_id_card_screen.dart';
import 'package:passy/screens/add_identity_screen.dart';
import 'package:passy/screens/add_password_screen.dart';
import 'package:passy/screens/add_payment_card_screen.dart';
import 'package:passy/screens/note_screen.dart';
import 'package:passy/screens/password_screen.dart';
import 'package:passy/screens/settings_screen.dart';

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
  final List<Widget> _notes = [const Text('Widgets not implemented')];
  final List<Widget> _paymentCards = [const Text('Widgets not implemented')];
  final List<Widget> _idCards = [const Text('Widgets not implemented')];
  final List<Widget> _identities = [const Text('Widgets not implemented')];

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

    // Add passwords
    for (Password p in _account.accountData.passwords) {
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
                  child: _account.accountData.passwordIcons.containsKey(p.icon)
                      ? Image.memory(
                          _account.accountData.passwordIcons[p.icon]!)
                      : SvgPicture.asset(
                          logoCircleSvg,
                          width: 50,
                          color: Colors.purple,
                        ),
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
                const Icon(Icons.keyboard_arrow_right_rounded),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          Row(
            children: [
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
          ListView(
            children: _passwords,
            controller: ScrollController(),
          ),
          ListView(
            children: _notes,
            controller: ScrollController(),
          ),
          ListView(
            children: _paymentCards,
            controller: ScrollController(),
          ),
          ListView(
            children: _idCards,
            controller: ScrollController(),
          ),
          ListView(
            children: _identities,
            controller: ScrollController(),
          ),
        ],
      ),
    );
  }
}
