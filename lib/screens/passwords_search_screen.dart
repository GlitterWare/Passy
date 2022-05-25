import 'package:flutter/material.dart';
import 'package:passy/widgets/passy_back_button.dart';

class PasswordsSearchScreen extends StatefulWidget {
  const PasswordsSearchScreen({Key? key}) : super(key: key);

  static const routeName = '/main/passwords/search';

  @override
  State<StatefulWidget> createState() => _PasswordsSearchScreen();
}

class _PasswordsSearchScreen extends State<PasswordsSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(child: Text('Note')),
      ),
    );
  }
}
