import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';

class AddPaymentCardScreen extends StatefulWidget {
  const AddPaymentCardScreen({Key? key}) : super(key: key);

  static const routeName = '/addPaymentCard';

  @override
  State<StatefulWidget> createState() => _AddPaymentCardScreen();
}

class _AddPaymentCardScreen extends State<AddPaymentCardScreen> {
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
        title: const Center(child: Text('Settings')),
      ),
    );
  }
}
