import 'package:flutter/material.dart';
import 'package:passy/widgets/passy_back_button.dart';

class EditPaymentCardScreen extends StatefulWidget {
  const EditPaymentCardScreen({Key? key}) : super(key: key);

  static const routeName = '/main/paymentCards/editPaymentCard';

  @override
  State<StatefulWidget> createState() => _EditPaymentCardScreen();
}

class _EditPaymentCardScreen extends State<EditPaymentCardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(child: Text('Settings')),
      ),
    );
  }
}
