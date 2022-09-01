import 'package:flutter/material.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/screens/assets.dart';
import 'package:passy/screens/password_screen.dart';

import 'widgets.dart';

class PasswordButton extends StatelessWidget {
  final Password password;

  const PasswordButton({
    Key? key,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThreeWidgetButton(
      left: password.website == ''
          ? logoCircle50White
          : FavIconImage(address: password.website),
      right: const Icon(Icons.arrow_forward_ios_rounded),
      onPressed: () => Navigator.pushNamed(context, PasswordScreen.routeName,
          arguments: password),
      center: Column(
        children: [
          Align(
            child: Text(
              password.nickname,
            ),
            alignment: Alignment.centerLeft,
          ),
          Align(
            child: Text(
              password.username,
              style: const TextStyle(color: Colors.grey),
            ),
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
    );
  }
}
