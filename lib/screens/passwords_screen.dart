import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/passwords_search_screen.dart';
import 'package:passy/widgets/passy_back_button.dart';

import 'edit_password_screen.dart';

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  static const routeName = '/main/passwords';

  @override
  State<StatefulWidget> createState() => _PasswordsScreen();
}

class _PasswordsScreen extends State<PasswordsScreen> {
  final List<Widget> _passwordWidgets = [];

  @override
  void initState() {
    super.initState();
    List<Widget> _widgets =
        buildPasswordWidgets(context: context, account: data.loadedAccount!);
    _passwordWidgets.addAll(_widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(onPressed: () => Navigator.pop(context)),
        title: const Center(child: Text('Passwords')),
        actions: [
          IconButton(
            padding: appBarButtonPadding,
            splashRadius: appBarButtonSplashRadius,
            onPressed: () =>
                Navigator.pushNamed(context, PasswordsSearchScreen.routeName),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            padding: appBarButtonPadding,
            splashRadius: appBarButtonSplashRadius,
            onPressed: () =>
                Navigator.pushNamed(context, EditPasswordScreen.routeName),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(children: _passwordWidgets),
    );
  }
}
