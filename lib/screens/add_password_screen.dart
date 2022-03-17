import 'package:flutter/material.dart';

class AddPasswordScreen extends StatefulWidget {
  const AddPasswordScreen({Key? key}) : super(key: key);

  static const routeName = '/addPassword';

  @override
  State<StatefulWidget> createState() => _AddPasswordScreen();
}

class _AddPasswordScreen extends State<AddPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    );
  }
}
