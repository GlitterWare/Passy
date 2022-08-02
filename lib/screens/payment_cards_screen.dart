import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/payment_card.dart';

import 'theme.dart';
import 'common.dart';
import 'edit_payment_card_screen.dart';
import 'main_screen.dart';
import 'search_screen.dart';
import 'payment_card_screen.dart';

class PaymentCardsScreen extends StatefulWidget {
  const PaymentCardsScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/paymentCards';

  @override
  State<StatefulWidget> createState() => _PaymentCardsScreen();
}

class _PaymentCardsScreen extends State<PaymentCardsScreen> {
  final List<Widget> _paymentCardWidgets = [];

  @override
  void initState() {
    super.initState();
    List<Widget> _widgets = buildPaymentCardWidgets(
      context,
      paymentCards: data.loadedAccount!.paymentCards,
      onPressed: (paymentCard) => Navigator.pushNamed(
          context, PaymentCardScreen.routeName,
          arguments: paymentCard),
    );
    _paymentCardWidgets.addAll(_widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: getBackButton(onPressed: () => Navigator.pop(context)),
        title: const Center(child: Text('Payment cards')),
        actions: [
          IconButton(
            padding: appBarButtonPadding,
            splashRadius: appBarButtonSplashRadius,
            onPressed: () => Navigator.pushNamed(
              context,
              SearchScreen.routeName,
              arguments: (String terms) {
                final List<PaymentCard> _found = [];
                final List<String> _terms =
                    terms.trim().toLowerCase().split(' ');
                for (PaymentCard _paymentCard
                    in data.loadedAccount!.paymentCards) {
                  {
                    bool testPaymentCard(PaymentCard value) =>
                        _paymentCard.key == value.key;

                    if (_found.any(testPaymentCard)) continue;
                  }
                  {
                    int _positiveCount = 0;
                    for (String _term in _terms) {
                      if (_paymentCard.cardholderName
                          .toLowerCase()
                          .contains(_term)) {
                        _positiveCount++;
                        continue;
                      }
                      if (_paymentCard.nickname.toLowerCase().contains(_term)) {
                        _positiveCount++;
                        continue;
                      }
                      if (_paymentCard.exp.toLowerCase().contains(_term)) {
                        _positiveCount++;
                        continue;
                      }
                    }
                    if (_positiveCount == _terms.length) {
                      _found.add(_paymentCard);
                    }
                  }
                }
                List<Widget> _widgets = buildPaymentCardWidgets(
                  context,
                  paymentCards: _found,
                  onPressed: (paymentCard) => Navigator.pushNamed(
                      context, PaymentCardScreen.routeName,
                      arguments: paymentCard),
                );
                return _widgets;
              },
            ),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            padding: appBarButtonPadding,
            splashRadius: appBarButtonSplashRadius,
            onPressed: () =>
                Navigator.pushNamed(context, EditPaymentCardScreen.routeName),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(children: _paymentCardWidgets),
    );
  }
}
