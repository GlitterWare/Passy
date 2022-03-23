import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy/id_card.dart';

class AddIdCardScreen extends StatefulWidget {
  const AddIdCardScreen({Key? key}) : super(key: key);

  static const routeName = '/addIdCard';

  @override
  State<StatefulWidget> createState() => _AddIdCardScreen();
}

class _AddIdCardScreen extends State<AddIdCardScreen> {
  late Widget _backButton;

  @override
  void initState() {
    super.initState();
    _backButton = getBackButton(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
        title: const Center(child: Text('Add ID Card')),
      ),
    );
  }
}
