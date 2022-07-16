import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/widgets/passy_back_button.dart';

class PasswordsSearchScreen extends StatefulWidget {
  const PasswordsSearchScreen({Key? key}) : super(key: key);

  static const routeName = '/main/passwords/search';

  @override
  State<StatefulWidget> createState() => _PasswordsSearchScreen();
}

class _PasswordsSearchScreen extends State<PasswordsSearchScreen> {
  List<String> _terms = [];
  final List<Password> _found = [];
  final LoadedAccount _account = data.loadedAccount!;
  final Iterable<Password> _passwords = data.loadedAccount!.passwords;

  void _search(String terms) {
    _found.clear();
    _terms = terms.trim().toLowerCase().split(' ');
    for (Password _password in _passwords) {
      {
        bool testPassword(Password value) => _password.key == value.key;

        if (_found.any(testPassword)) continue;
      }
      bool testNick(String value) =>
          _password.nickname.toLowerCase().contains(value);
      bool testUsrnm(String value) =>
          _password.username.toLowerCase().contains(value);
      if (_terms.any(testUsrnm)) {
        _found.add(_password);
        continue;
      }
      if (_terms.any(testNick)) {
        _found.add(_password);
        continue;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(child: Text('Search')),
      ),
      body: Column(
        children: [
          Padding(
            padding: entryPadding,
            child: TextFormField(
              decoration: const InputDecoration(
                label: Text('Search'),
                hintText: 'github human@example.com',
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _found.length,
              itemBuilder: (BuildContext context, int index) =>
                  buildPasswordWidget(
                context: context,
                account: _account,
                password: _found[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
