import 'package:flutter/material.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/identity_screen.dart';

class IdentityWidget extends StatelessWidget {
  final Identity _identity;

  const IdentityWidget({Key? key, required Identity identity})
      : _identity = identity,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return getThreeWidgetButton(
      right: const Icon(Icons.arrow_forward_ios_rounded),
      onPressed: () => Navigator.pushNamed(context, IdentityScreen.routeName,
          arguments: _identity),
      center: Column(
        children: [
          Align(
            child: Text(
              _identity.nickname,
            ),
            alignment: Alignment.centerLeft,
          ),
          Align(
            child: Text(
              _identity.firstAddressLine,
              style: const TextStyle(color: Colors.grey),
            ),
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
    );
  }
}
