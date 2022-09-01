import 'package:flutter/material.dart';

import 'package:passy/passy_data/id_card.dart';
import 'package:passy/widgets/widgets.dart';

class IDCardWidget extends StatelessWidget {
  final IDCard idCard;
  final void Function()? onPressed;

  const IDCardWidget({
    Key? key,
    required this.idCard,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThreeWidgetButton(
      left: const Icon(Icons.perm_identity_outlined),
      right: const Icon(Icons.arrow_forward_ios_rounded),
      onPressed: onPressed,
      center: Column(
        children: [
          Align(
            child: Text(
              idCard.nickname,
            ),
            alignment: Alignment.centerLeft,
          ),
          Align(
            child: Text(
              idCard.name,
              style: const TextStyle(color: Colors.grey),
            ),
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
    );
  }
}
