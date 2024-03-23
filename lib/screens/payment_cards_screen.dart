import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

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
  List<String> _tags = [];
  bool _isLoading = false;

  void _onSearchPressed({String? tag}) {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(
          entryType: EntryType.paymentCard,
          selectedTags: tag == null ? [] : [tag],
          builder: (String terms, List<String> tags, void Function() rebuild) {
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
                bool _tagMismatch = false;
                for (String tag in tags) {
                  if (!_paymentCard.tags.contains(tag)) {
                    _tagMismatch = true;
                    break;
                  }
                }
                if (_tagMismatch) continue;
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
            if (_found.isEmpty) {
              return CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
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

  Future<void> _load() async {
    _isLoading = true;
    List<String> newTags;
    try {
      newTags = await _account.paymentCardTags;
    } catch (_) {
      return;
    }
    if (listEquals(newTags, _tags)) {
      return;
    }
    if (mounted) {
      setState(() {
        _tags = newTags;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading) _load().whenComplete(() => _isLoading = false);
    List<PaymentCardMeta> _paymentCards = [];
    try {
      _paymentCards = _account.paymentCardsMetadata.values.toList();
    } catch (_) {}
    return Scaffold(
      appBar: EntriesScreenAppBar(
        entryType: EntryType.paymentCard,
        title: Center(child: Text(localizations.paymentCards)),
        onAddPressed: _onAddPressed,
        onSearchPressed: _onSearchPressed,
      ),
      body: _paymentCards.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
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
                if (_tags.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: PassyTheme.passyPadding.top / 2,
                          bottom: PassyTheme.passyPadding.bottom / 2),
                      child: EntryTagList(
                        notSelected: _tags,
                        onAdded: (tag) => setState(() {
                          _onSearchPressed(tag: tag);
                        }),
                      ),
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
