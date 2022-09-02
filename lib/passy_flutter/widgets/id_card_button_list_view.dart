import 'package:flutter/material.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class IDCardButtonListView extends StatelessWidget {
  final List<IDCard> idCards;
  final bool shouldSort;
  final void Function(IDCard idCard)? onPressed;

  const IDCardButtonListView({
    Key? key,
    required this.idCards,
    this.shouldSort = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortIDCards(idCards);
    return ListView(
      children: [
        for (IDCard idCard in idCards)
          PassyPadding(IDCardButton(
            idCard: idCard,
            onPressed: () => onPressed?.call(idCard),
          )),
      ],
    );
  }
}
