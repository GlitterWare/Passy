import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  String _title = 'Passwords';

  final List<Widget> _passwords = [];
  final List<Widget> _notes = [];
  final List<Widget> _paymentCards = [];
  final List<Widget> _idCards = [];
  final List<Widget> _identities = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset('assets/images/logo_circle.svg'),
                splashRadius: 20,
                iconSize: 40,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(_title),
              ),
            ],
          ),
          actions: [
            ButtonBar(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded),
                  splashRadius: 20,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search_rounded),
                  splashRadius: 20,
                )
              ],
            ),
          ],
          bottom: TabBar(
            onTap: (value) {
              switch (value) {
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
            },
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
      ),
    );
  }
}
