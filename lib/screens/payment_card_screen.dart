import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/passy_flutter/passy_theme.dart';

import 'main_screen.dart';
import 'edit_payment_card_screen.dart';
import 'payment_cards_screen.dart';
import 'splash_screen.dart';

class PaymentCardScreen extends StatefulWidget {
  const PaymentCardScreen({Key? key}) : super(key: key);

  static const routeName = '/paymentCard';

  @override
  State<StatefulWidget> createState() => _PaymentCardScreen();
}

class _PaymentCardScreen extends State<PaymentCardScreen> {
  void _onRemovePressed(PaymentCard paymentCard) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: PassyTheme.dialogShape,
            title: const Text('Remove payment card'),
            content:
                const Text('Payment cards can only be restored from a backup.'),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style:
                      TextStyle(color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text(
                  'Remove',
                  style:
                      TextStyle(color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () {
                  LoadedAccount _account = data.loadedAccount!;
                  Navigator.pushNamed(context, SplashScreen.routeName);
                  _account.removePaymentCard(paymentCard.key).whenComplete(() {
                    Navigator.popUntil(context,
                        (r) => r.settings.name == MainScreen.routeName);
                    Navigator.pushNamed(context, PaymentCardsScreen.routeName);
                  });
                },
              )
            ],
          );
        });
  }

  void _onEditPressed(PaymentCard paymentCard) {
    Navigator.pushNamed(
      context,
      EditPaymentCardScreen.routeName,
      arguments: paymentCard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final PaymentCard _paymentCard =
        ModalRoute.of(context)!.settings.arguments as PaymentCard;
    return Scaffold(
      appBar: EntryScreenAppBar(
        title: const Center(child: Text('Payment Card')),
        onRemovePressed: () => _onRemovePressed(_paymentCard),
        onEditPressed: () => _onEditPressed(_paymentCard),
      ),
      body: ListView(children: [
        PaymentCardButton(
          paymentCard: _paymentCard.uncensoredMetadata,
          obscureCardNumber: false,
          obscureCardCvv: false,
          isSwipeGestureEnabled: false,
        ),
        if (_paymentCard.nickname != '')
          PassyPadding(RecordButton(
            title: 'Nickname',
            value: _paymentCard.nickname,
          )),
        if (_paymentCard.cardNumber != '')
          PassyPadding(RecordButton(
            title: 'Card number',
            value: _paymentCard.cardNumber,
          )),
        if (_paymentCard.cardholderName != '')
          PassyPadding(RecordButton(
            title: 'Card holder name',
            value: _paymentCard.cardholderName,
          )),
        if (_paymentCard.exp != '')
          PassyPadding(RecordButton(
            title: 'Expiration date',
            value: _paymentCard.exp,
          )),
        if (_paymentCard.cvv != '')
          PassyPadding(RecordButton(
            title: 'CVV',
            value: _paymentCard.cvv,
          )),
        for (CustomField _customField in _paymentCard.customFields)
          PassyPadding(CustomFieldButton(customField: _customField)),
        if (_paymentCard.additionalInfo != '')
          PassyPadding(RecordButton(
            title: 'Additional info',
            value: _paymentCard.additionalInfo,
          )),
      ]),
    );
  }
}
