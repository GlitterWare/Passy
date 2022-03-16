import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/state.dart';
import 'package:passy/passy/loaded_account.dart';

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
  final List<Widget> _notes = [];
  final List<Widget> _paymentCards = [];
  final List<Widget> _idCards = [];
  final List<Widget> _identities = [];

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(_title),
            ),
          ],
        ),
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
          Column(
            children: _passwords,
          ),
          Column(
            children: _notes,
          ),
          Column(
            children: _paymentCards,
          ),
          Column(
            children: _idCards,
          ),
          Column(
            children: _identities,
          ),
        ],
      ),
    );
  }
}
