import 'package:flutter/material.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class PaymentCardButtonMiniListView extends StatelessWidget {
  final List<PaymentCardMeta> paymentCards;
  final bool shouldSort;
  final void Function(PaymentCardMeta paymentCard)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
          BuildContext context, PaymentCardMeta paymentCardMeta)?
      popupMenuItemBuilder;

  const PaymentCardButtonMiniListView({
    Key? key,
    required this.paymentCards,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortPaymentCards(paymentCards);
    return ListView(
      children: [
        for (PaymentCardMeta paymentCard in paymentCards)
          PassyPadding(PaymentCardButtonMini(
            paymentCard: paymentCard,
            onPressed: onPressed == null ? null : () => onPressed!(paymentCard),
            popupMenuItemBuilder: popupMenuItemBuilder == null
                ? null
                : (context) => popupMenuItemBuilder!(context, paymentCard),
          )),
      ],
    );
  }
}
