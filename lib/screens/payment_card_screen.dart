import 'package:flutter/material.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/widgets/passy_back_button.dart';

class PaymentCardScreen extends StatefulWidget {
  const PaymentCardScreen({Key? key}) : super(key: key);

  static const routeName = '/main/paymentCard';

  @override
  State<StatefulWidget> createState() => _PaymentCardScreen();
}

class _PaymentCardScreen extends State<PaymentCardScreen> {
  @override
  Widget build(BuildContext context) {
    final PaymentCard _paymentCard =
        ModalRoute.of(context)!.settings.arguments as PaymentCard;
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(child: Text('Payment Card')),
      ),
    );
  }
}
