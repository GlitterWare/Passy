import 'package:flutter/material.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class IDCardButtonListView extends StatelessWidget {
  final List<IDCardMeta> idCards;
  final bool shouldSort;
  final void Function(IDCardMeta idCard)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
      BuildContext context, IDCardMeta idCardMeta)? popupMenuItemBuilder;
  final List<Widget>? topWidgets;

  const IDCardButtonListView({
    Key? key,
    required this.idCards,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
    this.topWidgets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortIDCards(idCards);
    return ListView(
      children: [
        if (topWidgets != null) ...topWidgets!,
        for (IDCardMeta idCard in idCards)
          PassyPadding(IDCardButton(
            idCard: idCard,
            onPressed: onPressed == null ? null : () => onPressed!(idCard),
            popupMenuItemBuilder: popupMenuItemBuilder == null
                ? null
                : (context) => popupMenuItemBuilder!(context, idCard),
          )),
      ],
    );
  }
}
