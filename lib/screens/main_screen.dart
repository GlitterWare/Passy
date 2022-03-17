import 'package:flutter/material.dart';
import 'package:passy/common/state.dart';
import 'package:passy/passy/loaded_account.dart';
import 'package:otp/otp.dart';
import 'package:passy/passy/password.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  String _title = 'Passwords';
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
          setState(() => _title = 'Passwords');
          break;
        case 1:
          setState(() => _title = 'Notes');
          break;
        case 2:
          setState(() => _title = 'Payment Cards');
          break;
        case 3:
          setState(() => _title = 'ID Cards');
          break;
        case 4:
          setState(() => _title = 'Identities');
          break;
      }
    });
    List<Password> _samplePasswords = [
      Password(
          nickname: 'Nickname',
          icon: 'assets/images/icon.png',
          username: 'username',
          password: '',
          website: '',
          tfaSecret: '',
          additionalInfo: ''),
      Password(
          nickname: 'Nickname',
          icon: 'assets/images/icon.png',
          username: 'username',
          password: '',
          website: '',
          tfaSecret: '',
          additionalInfo: ''),
      Password(
          nickname: 'Nickname',
          icon: 'assets/images/icon.png',
          username: 'username',
          password: '',
          website: '',
          tfaSecret: '',
          additionalInfo: ''),
      Password(
          nickname: 'Nickname',
          icon: 'assets/images/icon.png',
          username: 'username',
          password: '',
          website: '',
          tfaSecret: '',
          additionalInfo: ''),
      Password(
          nickname: 'Nickname',
          icon: 'assets/images/icon.png',
          username: 'username',
          password: '',
          website: '',
          tfaSecret: '',
          additionalInfo: ''),
      Password(
          nickname: 'Nickname',
          icon: 'assets/images/icon.png',
          username: 'username',
          password: '',
          website: '',
          tfaSecret: '',
          additionalInfo: ''),
      Password(
          nickname: 'Nickname',
          icon: 'assets/images/icon.png',
          username: 'username',
          password: '',
          website: '',
          tfaSecret: '',
          additionalInfo: ''),
      Password(
          nickname: 'Nickname',
          icon: 'assets/images/icon.png',
          username: 'username',
          password: '',
          website: '',
          tfaSecret: '',
          additionalInfo: ''),
    ];
    for (var _password in _samplePasswords) {
      _passwords.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
          child: ElevatedButton(
            onPressed: () {
              //TODO: push password window here
            },
            child: Padding(
              child: Row(
                children: [
                  Padding(
                    child: ImageIcon(
                      AssetImage(_password.icon),
                      size: 50,
                      color: Colors.purple,
                    ),
                    padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                  ),
                  Column(
                    children: [
                      Text(_password.nickname),
                      Text(_password.username),
                    ],
                  ),
                  const Flexible(
                    child: Align(
                      child: Icon(Icons.keyboard_arrow_right_rounded),
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            ),
            style: ElevatedButton.styleFrom(
                primary: Colors.white, onPrimary: Colors.black),
          ),
        ),
      );
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
                onPressed: () {},
                icon: const Icon(Icons.settings),
                splashRadius: 20,
              ),
              IconButton(
                onPressed: () {},
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
          ),
          ListView(
            children: _notes,
          ),
          ListView(
            children: _paymentCards,
          ),
          ListView(
            children: _idCards,
          ),
          ListView(
            children: _identities,
          ),
        ],
      ),
    );
  }
}
