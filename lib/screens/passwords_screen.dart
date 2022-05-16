import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:passy/common/assets.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/widgets/arrow_button.dart';

import 'edit_password_screen.dart';
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
    _backButton = getBackButton(
        onPressed: () =>
            Navigator.pushReplacementNamed(context, MainScreen.routeName));

    for (Password password in _account.passwords) {
      Widget _getIcon(String name) {
        Uint8List? _icon = _account.getPasswordIcon(name)?.value;
        if (_icon == null) {
          return SvgPicture.asset(
            logoCircleSvg,
            width: 50,
            color: Colors.white,
          );
        }
        return Image.memory(_icon);
      }

      _passwords.add(ArrowButton(
        icon: _getIcon(password.iconName),
        onPressed: () {
          Navigator.pushNamed(context, PasswordScreen.routeName,
              arguments: password);
        },
        body: Column(
          children: [
            Align(
              child: Text(
                password.nickname,
              ),
              alignment: Alignment.centerLeft,
            ),
            Align(
              child: Text(
                password.username,
                style: const TextStyle(color: Colors.grey),
              ),
              alignment: Alignment.centerLeft,
            ),
          ],
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
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, EditPasswordScreen.routeName),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(children: _passwords),
    );
  }
}
