import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/payment_card.dart';

import '../common/theme.dart';
import 'main_screen.dart';
import 'common.dart';
import 'edit_payment_card_screen.dart';
import 'payment_cards_screen.dart';

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
            shape: dialogShape,
            title: const Text('Remove payment card'),
            content:
                const Text('Payment cards can only be restored from a backup.'),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  'Remove',
                  style: TextStyle(color: lightContentSecondaryColor),
                ),
                onPressed: () {
                  LoadedAccount _account = data.loadedAccount!;
                  _account.removePaymentCard(paymentCard.key);
                  Navigator.popUntil(
                      context, (r) => r.settings.name == MainScreen.routeName);
                  _account.save().whenComplete(() => Navigator.pushNamed(
                      context, PaymentCardsScreen.routeName));
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
      appBar: getEntryScreenAppBar(
        context,
        title: const Center(child: Text('Payment Card')),
        onRemovePressed: () => _onRemovePressed(_paymentCard),
        onEditPressed: () => _onEditPressed(_paymentCard),
      ),
      body: ListView(children: [
        buildPaymentCardWidget(
          paymentCard: _paymentCard,
          obscureCardNumber: false,
          obscureCardCvv: false,
          isSwipeGestureEnabled: false,
        ),
        if (_paymentCard.nickname != '')
          buildRecord(context, 'Nickname', _paymentCard.nickname),
        if (_paymentCard.cardNumber != '')
          buildRecord(context, 'Card number', _paymentCard.cardNumber),
        if (_paymentCard.cardholderName != '')
          buildRecord(context, 'Card holder name', _paymentCard.cardholderName),
        if (_paymentCard.exp != '')
          buildRecord(context, 'Expiration date', _paymentCard.exp),
        if (_paymentCard.cvv != '')
          buildRecord(context, 'CVV', _paymentCard.cvv),
        for (CustomField customField in _paymentCard.customFields)
          buildRecord(context, customField.title, customField.value,
              obscureValue: customField.obscured,
              isPassword: customField.fieldType == FieldType.password),
        if (_paymentCard.additionalInfo != '')
          buildRecord(context, 'Additional info', _paymentCard.additionalInfo),
      ]),
    );
  }
}
