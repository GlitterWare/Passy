import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy/payment_card.dart';

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
    final PaymentCard? _paymentCard =
        ModalRoute.of(context)!.settings.arguments as PaymentCard?;
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
        title: _paymentCard == null
            ? const Text('Add Payment Card')
            : const Text('Edit Payment Card'),
      ),
    );
  }
}
