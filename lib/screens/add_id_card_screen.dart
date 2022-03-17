import 'package:flutter/material.dart';

class AddIdCardScreen extends StatefulWidget {
  const AddIdCardScreen({Key? key}) : super(key: key);

  static const routeName = '/addIdCard';

  @override
  State<StatefulWidget> createState() => _AddIdCardScreen();
}

class _AddIdCardScreen extends State<AddIdCardScreen> {
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
