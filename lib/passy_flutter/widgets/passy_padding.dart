import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/theme.dart';

class PassyPadding extends StatelessWidget {
  final Widget? child;

  const PassyPadding(
    this.child, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: PassyTheme.passyPadding,
        child: child,
      );
}
