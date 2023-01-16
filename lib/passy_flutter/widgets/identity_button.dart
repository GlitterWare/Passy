import 'package:flutter/material.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

class IdentityButton extends StatelessWidget {
  final IdentityMeta identity;
  final void Function()? onPressed;

  const IdentityButton({
    Key? key,
    required this.identity,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThreeWidgetButton(
      left: const Padding(
        padding: EdgeInsets.only(right: 30),
        child: Icon(Icons.people_outline_rounded),
      ),
      right: const Icon(Icons.arrow_forward_ios_rounded),
      onPressed: onPressed,
      center: Column(
        children: [
          Align(
            child: Text(
              identity.nickname,
            ),
            alignment: Alignment.centerLeft,
          ),
          Align(
            child: Text(
              identity.firstAddressLine,
              style: const TextStyle(color: Colors.grey),
            ),
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
    );
  }
}
