import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:passy/common/assets.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';

import 'add_password_screen.dart';
import 'password_screen.dart';

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  static const routeName = '/main/passwords';

  @override
  State<StatefulWidget> createState() => _PasswordsScreen();
}

class _PasswordsScreen extends State<PasswordsScreen> {
  Widget? _backButton;
  final List<Widget> _passwords = [];

  @override
  void initState() {
    super.initState();
    LoadedAccount _account = data.loadedAccount!;
    _backButton = getBackButton(context);

    for (Password p in _account.passwords) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
        title: const Center(child: Text('Passwords')),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
            splashRadius: 20,
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AddPasswordScreen.routeName),
            icon: const Icon(Icons.add_rounded),
            splashRadius: 20,
          ),
        ],
      ),
      body: ListView(children: _passwords),
    );
  }
}
