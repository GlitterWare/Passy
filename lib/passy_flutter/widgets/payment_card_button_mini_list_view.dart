import 'package:flutter/material.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_data/sync_entry_state.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class PaymentCardButtonMiniListView extends StatelessWidget {
  final List<PaymentCardMeta> paymentCards;
  final bool shouldSort;
  final void Function(PaymentCardMeta paymentCard)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
          BuildContext context, PaymentCardMeta paymentCardMeta)?
      popupMenuItemBuilder;
  final Map<String, SyncEntryState> syncStates;

  const PaymentCardButtonMiniListView({
    Key? key,
    required this.paymentCards,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
    Map<String, SyncEntryState>? syncStates,
  })  : syncStates = syncStates ?? const {},
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortPaymentCards(paymentCards);
    List<Widget> _entriesWidgets = [];
    for (PaymentCardMeta paymentCard in paymentCards) {
      SyncEntryState? state = syncStates[paymentCard.key];
      Widget? stateIcon;
      switch (state) {
        case null:
          break;
        case SyncEntryState.added:
          stateIcon = const Icon(Icons.add, color: Colors.green, size: 28);
          break;
        case SyncEntryState.removed:
          stateIcon = const Icon(Icons.remove, color: Colors.red, size: 28);
          break;
        case SyncEntryState.modified:
          stateIcon = const Icon(Icons.edit, color: Colors.yellow, size: 28);
          break;
      }
      _entriesWidgets.add(PassyPadding(PaymentCardButtonMini(
        leftWidget: stateIcon == null
            ? null
            : Padding(
                padding: EdgeInsets.fromLTRB(
                  PassyTheme.passyPadding.left,
                  PassyTheme.passyPadding.top,
                  PassyTheme.passyPadding.right * 2,
                  PassyTheme.passyPadding.bottom,
                ),
                child: stateIcon,
              ),
        paymentCard: paymentCard,
        onPressed: onPressed == null ? null : () => onPressed!(paymentCard),
        popupMenuItemBuilder: popupMenuItemBuilder == null
            ? null
            : (context) => popupMenuItemBuilder!(context, paymentCard),
      )));
    }
    return ListView(
      children: [
        ..._entriesWidgets,
      ],
    );
  }
}
