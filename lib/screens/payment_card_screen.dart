import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/widgets/record_widget.dart';
import 'package:passy/widgets/widgets.dart';

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
          PassyPadding(PassyRecord(
            title: 'Nickname',
            value: _paymentCard.nickname,
          )),
        if (_paymentCard.cardNumber != '')
          PassyPadding(PassyRecord(
            title: 'Card number',
            value: _paymentCard.cardNumber,
          )),
        if (_paymentCard.cardholderName != '')
          PassyPadding(PassyRecord(
            title: 'Card holder name',
            value: _paymentCard.cardholderName,
          )),
        if (_paymentCard.exp != '')
          PassyPadding(PassyRecord(
            title: 'Expiration date',
            value: _paymentCard.exp,
          )),
        if (_paymentCard.cvv != '')
          PassyPadding(PassyRecord(
            title: 'CVV',
            value: _paymentCard.cvv,
          )),
        for (CustomField _customField in _paymentCard.customFields)
          buildCustomField(context, _customField),
        if (_paymentCard.additionalInfo != '')
          PassyPadding(PassyRecord(
            title: 'Additional info',
            value: _paymentCard.additionalInfo,
          )),
      ]),
    );
  }
}
