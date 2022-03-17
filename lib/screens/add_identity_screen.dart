import 'package:flutter/material.dart';

class AddIdentityScreen extends StatefulWidget {
  const AddIdentityScreen({Key? key}) : super(key: key);

  static const routeName = '/addIdentity';

  @override
  State<StatefulWidget> createState() => _AddIdentityScreen();
}

class _AddIdentityScreen extends State<AddIdentityScreen> {
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
