import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';

class DoubleActionButton extends StatelessWidget {
  final Widget _child;
  final Widget _icon;
  final void Function() _onButtonPressed;
  final void Function() _onActionPressed;

  const DoubleActionButton(
      {Key? key,
      required Widget child,
      required Widget icon,
      required void Function() onButtonPressed,
      required void Function() onActionPressed})
      : _child = child,
        _icon = icon,
        _onButtonPressed = onButtonPressed,
        _onActionPressed = onActionPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
      padding: entryPadding,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 0),
          ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
          onPressed: _onButtonPressed,
          child: Row(
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: _child,
              ),
              IconButton(
                onPressed: _onActionPressed,
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 15.0),
                icon: _icon,
                splashRadius: 27,
              ),
            ],
          )));
}
