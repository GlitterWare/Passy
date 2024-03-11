import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/common/common.dart';

class PaymentCardButton extends StatelessWidget {
  final PaymentCardMeta paymentCard;
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
          InkWell(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            onTap: onPressed,
            child: ClipRect(
              child: Align(
                heightFactor: 0.857,
                widthFactor: 0.917,
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
                              colorFilter: const ColorFilter.mode(
                                  Colors.purple, BlendMode.srcIn),
                              width: 50,
                            ))
                      ],
                  cvvCode: '',
                  showBackView: false,
                  obscureCardNumber: obscureCardNumber,
                  obscureCardCvv: obscureCardCvv,
                  isHolderNameVisible: true,
                  isChipVisible: false,
                  backgroundImage: 'assets/images/payment_card_bg.png',
                  cardType: cardTypeFromNumber(
                      paymentCard.cardNumber.replaceAll('*', '0')),
                  isSwipeGestureEnabled: isSwipeGestureEnabled,
                  onCreditCardWidgetChange: (brand) {},
                  bankName: ' ',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 0, 0),
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
