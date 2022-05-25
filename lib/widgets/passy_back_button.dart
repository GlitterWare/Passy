import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';

class PassyBackButton extends StatelessWidget {
  final void Function()? _onPressed;

  const PassyBackButton({Key? key, void Function()? onPressed})
      : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) => IconButton(
        splashRadius: appBarButtonSplashRadius,
        padding: appBarButtonPadding,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: _onPressed,
      );
}
