import 'package:flutter/material.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class PaymentCardButtonListView extends StatelessWidget {
  final List<PaymentCard> paymentCards;
  final bool shouldSort;
  final void Function(PaymentCard paymentCard)? onPressed;

  const PaymentCardButtonListView({
    Key? key,
    required this.paymentCards,
    this.shouldSort = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortPaymentCards(paymentCards);
    return ListView(
      children: [
        for (PaymentCard paymentCard in paymentCards)
          PassyPadding(PaymentCardButton(
            paymentCard: paymentCard,
            onPressed: () => onPressed?.call(paymentCard),
          )),
      ],
    );
  }
}
