import 'package:flutter/material.dart';

import 'package:passy/passy_data/id_card.dart';
import 'package:passy/widgets/widgets.dart';

class IDCardWidget extends StatelessWidget {
  final IDCard _idCard;
  final void Function()? _onPressed;

  const IDCardWidget(
      {Key? key, required IDCard idCard, void Function()? onPressed})
      : _idCard = idCard,
        _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThreeWidgetButton(
      left: const Icon(Icons.perm_identity_outlined),
      right: const Icon(Icons.arrow_forward_ios_rounded),
      onPressed: _onPressed,
      center: Column(
        children: [
          Align(
            child: Text(
              _idCard.nickname,
            ),
            alignment: Alignment.centerLeft,
          ),
          Align(
            child: Text(
              _idCard.name,
              style: const TextStyle(color: Colors.grey),
            ),
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
    );
  }
}
