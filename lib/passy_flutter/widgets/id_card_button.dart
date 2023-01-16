import 'package:flutter/material.dart';

import 'package:passy/passy_data/id_card.dart';

import 'widgets.dart';

class IDCardButton extends StatelessWidget {
  final IDCardMeta idCard;
  final void Function()? onPressed;

  const IDCardButton({
    Key? key,
    required this.idCard,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThreeWidgetButton(
      left: const Padding(
        padding: EdgeInsets.only(right: 30),
        child: Icon(Icons.perm_identity_outlined),
      ),
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
