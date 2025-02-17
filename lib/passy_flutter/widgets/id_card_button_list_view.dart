import 'package:flutter/material.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/sync_entry_state.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class IDCardButtonListView extends StatelessWidget {
  final List<IDCardMeta> idCards;
  final bool shouldSort;
  final void Function(IDCardMeta idCard)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
      BuildContext context, IDCardMeta idCardMeta)? popupMenuItemBuilder;
  final List<Widget>? topWidgets;
  final Map<String, SyncEntryState> syncStates;

  const IDCardButtonListView({
    Key? key,
    required this.idCards,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
    this.topWidgets,
    Map<String, SyncEntryState>? syncStates,
  })  : syncStates = syncStates ?? const {},
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortIDCards(idCards);
    List<Widget> _entriesWidgets = [];
    for (IDCardMeta idCard in idCards) {
      SyncEntryState? state = syncStates[idCard.key];
      Widget? stateIcon;
      switch (state) {
        case null:
          break;
        case SyncEntryState.added:
          stateIcon = const Icon(Icons.add, color: Colors.green, size: 28);
          break;
        case SyncEntryState.removed:
          stateIcon =
              const Icon(Icons.delete_rounded, color: Colors.red, size: 28);
          break;
        case SyncEntryState.modified:
          stateIcon = const Icon(Icons.edit, color: Colors.yellow, size: 28);
          break;
      }
      _entriesWidgets.add(PassyPadding(IDCardButton(
        leftWidget: stateIcon == null
            ? null
            : Padding(
                padding: EdgeInsets.fromLTRB(
                  PassyTheme.of(context).passyPadding.left,
                  PassyTheme.of(context).passyPadding.top,
                  PassyTheme.of(context).passyPadding.right * 2,
                  PassyTheme.of(context).passyPadding.bottom,
                ),
                child: stateIcon,
              ),
        idCard: idCard,
        onPressed: onPressed == null ? null : () => onPressed!(idCard),
        popupMenuItemBuilder: popupMenuItemBuilder == null
            ? null
            : (context) => popupMenuItemBuilder!(context, idCard),
      )));
    }
    return ListView(
      children: [
        if (topWidgets != null) ...topWidgets!,
        ..._entriesWidgets,
      ],
    );
  }
}
