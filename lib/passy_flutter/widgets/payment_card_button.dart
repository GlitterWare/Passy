import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/common/common.dart';

class PaymentCardButton extends StatelessWidget {
  final PaymentCard paymentCard;
  final bool obscureCardNumber;
  final bool obscureCardCvv;
  final bool isSwipeGestureEnabled;
  final List<CustomCardTypeIcon>? customCardTypeIcons;
  final void Function()? onPressed;

  const PaymentCardButton({
    Key? key,
    required this.paymentCard,
    this.obscureCardNumber = true,
    this.obscureCardCvv = true,
    this.isSwipeGestureEnabled = false,
    this.customCardTypeIcons,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          TextButton(
            onPressed: onPressed,
            child: CreditCardWidget(
              glassmorphismConfig: Glassmorphism.defaultConfig(),
              width: 350,
              height: 200,
              cardNumber: beautifyCardNumber(paymentCard.cardNumber),
              expiryDate: paymentCard.exp,
              cardHolderName: paymentCard.cardholderName,
              customCardTypeIcons: customCardTypeIcons ??
                  [
                    CustomCardTypeIcon(
                        cardType: CardType.otherBrand,
                        cardImage: SvgPicture.asset(
                          'assets/images/logo_circle.svg',
                          color: Colors.purple,
                          width: 50,
                        ))
                  ],
              cvvCode: paymentCard.cvv,
              showBackView: false,
              obscureCardNumber: obscureCardNumber,
              obscureCardCvv: obscureCardCvv,
              isHolderNameVisible: true,
              backgroundImage: 'assets/images/payment_card_bg.png',
              cardType: cardTypeFromNumber(paymentCard.cardNumber),
              isSwipeGestureEnabled: isSwipeGestureEnabled,
              onCreditCardWidgetChange: (brand) {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(35, 32, 0, 0),
            child: Text(
              paymentCard.nickname,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
