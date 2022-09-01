import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';

class PassyPadding extends StatelessWidget {
  final Widget? _child;

  const PassyPadding(
    Widget? child, {
    Key? key,
  })  : _child = child,
        super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: passyPadding,
        child: _child,
      );
}
