import 'package:flutter/material.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/screens/identity_screen.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

class IdentityButton extends StatelessWidget {
  final Identity identity;

  const IdentityButton({
    Key? key,
    required this.identity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThreeWidgetButton(
      right: const Icon(Icons.arrow_forward_ios_rounded),
      onPressed: () => Navigator.pushNamed(context, IdentityScreen.routeName,
          arguments: identity),
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
