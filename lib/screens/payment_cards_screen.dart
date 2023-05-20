import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

import '../passy_data/entry_type.dart';
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
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(
      builder: (String terms) {
        final List<PaymentCardMeta> _found = [];
        final List<String> _terms = terms.trim().toLowerCase().split(' ');
        for (PaymentCardMeta _paymentCard
            in data.loadedAccount!.paymentCardsMetadata.values) {
          {
            bool testPaymentCard(PaymentCardMeta value) =>
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
        if (_found.isEmpty) {
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Column(
                  children: [
                    const Spacer(flex: 7),
                    Text(
                      localizations.noSearchResults,
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 7),
                  ],
                ),
              ),
            ],
          );
        }
        return PaymentCardButtonListView(
          paymentCards: _found,
          shouldSort: true,
          onPressed: (paymentCard) => {
            Navigator.pushNamed(context, PaymentCardScreen.routeName,
                arguments: _account.getPaymentCard(paymentCard.key)),
          },
        );
      },
    ));
  }

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditPaymentCardScreen.routeName);

  @override
  Widget build(BuildContext context) {
    List<PaymentCardMeta> _paymentCards =
        _account.paymentCardsMetadata.values.toList();
    return Scaffold(
      appBar: EntriesScreenAppBar(
        entryType: EntryType.paymentCard,
        title: Text(localizations.paymentCards),
        onAddPressed: _onAddPressed,
        onSearchPressed: _onSearchPressed,
      ),
      body: _paymentCards.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      Text(
                        localizations.noPaymentCards,
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
              topWidgets: [
                PassyPadding(
                  ThreeWidgetButton(
                    left: const Icon(Icons.add_rounded),
                    center: Text(
                      localizations.addPaymentCard,
                      textAlign: TextAlign.center,
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () => Navigator.pushNamed(
                        context, EditPaymentCardScreen.routeName),
                  ),
                ),
              ],
              paymentCards: _paymentCards,
              shouldSort: true,
              onPressed: (paymentCard) => {
                Navigator.pushNamed(context, PaymentCardScreen.routeName,
                    arguments: _account.getPaymentCard(paymentCard.key)),
              },
            ),
    );
  }
}
