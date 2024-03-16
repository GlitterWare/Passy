import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class PaymentCardButtonMini extends StatelessWidget {
  final PaymentCardMeta paymentCard;
  final void Function()? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(BuildContext context)?
      popupMenuItemBuilder;

  const PaymentCardButtonMini({
    Key? key,
    required this.paymentCard,
    this.onPressed,
    this.popupMenuItemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CardType _cardType =
        cardTypeFromNumber(paymentCard.cardNumber.replaceAll('*', '0'));
    return Row(children: [
      Flexible(
        child: ThreeWidgetButton(
          left: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: getCardTypeImage(_cardType)),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: onPressed,
          center: Column(
            children: [
              Align(
                child: Text(
                  paymentCard.nickname,
                ),
                alignment: Alignment.centerLeft,
              ),
              Align(
                child: Text(
                  paymentCard.cardholderName,
                  style: const TextStyle(color: Colors.grey),
                ),
                alignment: Alignment.centerLeft,
              ),
            ],
          ),
        ),
      ),
      if (popupMenuItemBuilder != null)
        FittedBox(
          child: PopupMenuButton(
            shape: PassyTheme.dialogShape,
            icon: const Icon(Icons.more_vert_rounded),
            padding: const EdgeInsets.fromLTRB(12, 22, 12, 22),
            splashRadius: 24,
            itemBuilder: popupMenuItemBuilder!,
          ),
        )
    ]);
  }
}
