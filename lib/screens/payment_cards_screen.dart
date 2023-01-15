import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

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
  final LoadedAccount _account = data.loadedAccount!;

  void _onSearchPressed() {
    Navigator.pushNamed(
      context,
      SearchScreen.routeName,
      arguments: (String terms) {
        final List<PaymentCard> _found = [];
        final List<String> _terms = terms.trim().toLowerCase().split(' ');
        for (PaymentCard _paymentCard
            in data.loadedAccount!.paymentCards.values) {
          {
            bool testPaymentCard(PaymentCard value) =>
                _paymentCard.key == value.key;

            if (_found.any(testPaymentCard)) continue;
          }
          {
            int _positiveCount = 0;
            for (String _term in _terms) {
              if (_paymentCard.cardholderName.toLowerCase().contains(_term)) {
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
        return PaymentCardButtonListView(
          paymentCards: _found,
          shouldSort: true,
          onPressed: (paymentCard) => {
            Navigator.pushNamed(context, PaymentCardScreen.routeName,
                arguments: paymentCard),
          },
        );
      },
    );
  }

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditPaymentCardScreen.routeName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EntriesScreenAppBar(
        title: const Text('Payment cards'),
        onAddPressed: _onAddPressed,
        onSearchPressed: _onSearchPressed,
      ),
      body: _account.paymentCards.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      const Text(
                        'No payment cards',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                          child: const Icon(Icons.add_rounded),
                          onPressed: () => Navigator.pushNamed(
                              context, EditPaymentCardScreen.routeName)),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            )
          : PaymentCardButtonListView(
              paymentCards: _account.paymentCards.values.toList(),
              shouldSort: true,
              onPressed: (paymentCard) => {
                Navigator.pushNamed(context, PaymentCardScreen.routeName,
                    arguments: paymentCard),
              },
            ),
    );
  }
}
