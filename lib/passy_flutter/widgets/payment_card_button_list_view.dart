import 'package:flutter/material.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class PaymentCardButtonListView extends StatelessWidget {
  final List<PaymentCardMeta> paymentCards;
  final bool shouldSort;
  final void Function(PaymentCardMeta paymentCard)? onPressed;
  final List<Widget>? topWidgets;

  const PaymentCardButtonListView({
    Key? key,
    required this.paymentCards,
    this.shouldSort = false,
    this.onPressed,
    this.topWidgets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortPaymentCards(paymentCards);
    return ListView(
      children: [
        if (topWidgets != null) ...topWidgets!,
        for (PaymentCardMeta paymentCard in paymentCards)
          PassyPadding(PaymentCardButton(
            paymentCard: paymentCard,
            onPressed: onPressed == null ? null : () => onPressed!(paymentCard),
          )),
      ],
    );
  }
}
