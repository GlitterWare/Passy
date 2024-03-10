import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/screens/common.dart';

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
  final _account = data.loadedAccount!;
  bool isFavorite = false;
  PaymentCard? _paymentCard;
  List<String> _tags = [];
  List<String> _selected = [];

  void _onRemovePressed(PaymentCard paymentCard) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: PassyTheme.dialogShape,
            title: Text(localizations.removePaymentCard),
            content: Text(
                '${localizations.paymentCardsCanOnlyBeRestoredFromABackup}.'),
            actions: [
              TextButton(
                child: Text(
                  localizations.cancel,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  localizations.remove,
                  style: const TextStyle(color: Colors.red),
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

  Future<void> _load() async {
    List<String> newTags = await _account.paymentCardTags;
    if (mounted) {
      setState(() {
        _tags = newTags;
        _selected = _paymentCard!.tags.toList();
        for (String tag in _selected) {
          if (_tags.contains(tag)) {
            _tags.remove(tag);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_paymentCard == null) {
      _paymentCard = ModalRoute.of(context)!.settings.arguments as PaymentCard;
      _load();
    }
    _account.reloadFavoritesSync();
    isFavorite = _account.favoritePaymentCards[_paymentCard!.key]?.status ==
        EntryStatus.alive;

    return Scaffold(
      appBar: EntryScreenAppBar(
        entryType: EntryType.paymentCard,
        entryKey: _paymentCard!.key,
        title: Center(child: Text(localizations.paymentCard)),
        onRemovePressed: () => _onRemovePressed(_paymentCard!),
        onEditPressed: () => _onEditPressed(_paymentCard!),
        isFavorite: isFavorite,
        onFavoritePressed: () async {
          if (isFavorite) {
            await _account.removeFavoritePaymentCard(_paymentCard!.key);
            showSnackBar(context,
                message: localizations.removedFromFavorites,
                icon: const Icon(
                  Icons.star_outline_rounded,
                  color: PassyTheme.darkContentColor,
                ));
          } else {
            await _account.addFavoritePaymentCard(_paymentCard!.key);
            showSnackBar(context,
                message: localizations.addedToFavorites,
                icon: const Icon(
                  Icons.star_rounded,
                  color: PassyTheme.darkContentColor,
                ));
          }
          setState(() {});
        },
      ),
      body: ListView(children: [
        PaymentCardButton(
          paymentCard: _paymentCard!.uncensoredMetadata,
          obscureCardNumber: false,
          obscureCardCvv: false,
          isSwipeGestureEnabled: false,
        ),

        Center(
          child: Padding(
            padding: EdgeInsets.only(
                top: PassyTheme.passyPadding.top / 2,
                bottom: PassyTheme.passyPadding.bottom / 2),
            child: EntryTagList(
              showAddButton: true,
              selected: _selected,
              notSelected: _tags,
              onAdded: (tag) async {
                Navigator.pushNamed(context, SplashScreen.routeName);
                _paymentCard!.tags = _selected.toList();
                _paymentCard!.tags.add(tag);
                await _account.setPaymentCard(_paymentCard!);
                Navigator.popUntil(
                    context,
                    (route) =>
                        route.settings.name == PaymentCardScreen.routeName);
                if (!mounted) return;
                setState(() {
                  _tags.remove(tag);
                  _selected.add(tag);
                  _selected.sort();
                  _paymentCard!.tags = _selected;
                });
              },
              onRemoved: (tag) async {
                Navigator.pushNamed(context, SplashScreen.routeName);
                _paymentCard!.tags = _selected.toList();
                _paymentCard!.tags.remove(tag);
                await _account.setPaymentCard(_paymentCard!);
                Navigator.popUntil(
                    context,
                    (route) =>
                        route.settings.name == PaymentCardScreen.routeName);
                if (!mounted) return;
                setState(() {
                  _tags.add(tag);
                  _tags.sort();
                  _selected.remove(tag);
                  _paymentCard!.tags = _selected;
                });
              },
            ),
          ),
        ),
        if (_paymentCard!.attachments.isNotEmpty)
          AttachmentsListView(files: _paymentCard!.attachments),
        if (_paymentCard!.nickname != '')
          PassyPadding(RecordButton(
            title: localizations.nickname,
            value: _paymentCard!.nickname,
          )),
        if (_paymentCard!.cardNumber != '')
          PassyPadding(RecordButton(
            title: localizations.cardNumber,
            value: _paymentCard!.cardNumber,
          )),
        if (_paymentCard!.cardholderName != '')
          PassyPadding(RecordButton(
            title: localizations.cardHolderName,
            value: _paymentCard!.cardholderName,
          )),
        if (_paymentCard!.exp != '')
          PassyPadding(RecordButton(
            title: localizations.expirationDate,
            value: _paymentCard!.exp,
          )),
        if (_paymentCard!.cvv != '')
          PassyPadding(RecordButton(
            title: 'CVV',
            value: _paymentCard!.cvv,
            obscureValue: true,
          )),
        for (CustomField _customField in _paymentCard!.customFields)
          PassyPadding(CustomFieldButton(customField: _customField)),
        if (_paymentCard!.additionalInfo != '')
          PassyPadding(RecordButton(
            title: localizations.additionalInfo,
            value: _paymentCard!.additionalInfo,
          )),
      ]),
    );
  }
}
