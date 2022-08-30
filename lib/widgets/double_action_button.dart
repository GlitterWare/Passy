import 'package:flutter/material.dart';

class DoubleActionButton extends StatelessWidget {
  final Widget _body;
  final Widget _icon;
  final void Function()? _onButtonPressed;
  final void Function()? _onActionPressed;

  const DoubleActionButton({
    Key? key,
    required Widget body,
    required Widget icon,
    void Function()? onButtonPressed,
    void Function()? onActionPressed,
  })  : _body = body,
        _icon = icon,
        _onButtonPressed = onButtonPressed,
        _onActionPressed = onActionPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: key,
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
            child: _body,
          ),
          IconButton(
            onPressed: _onActionPressed,
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            icon: _icon,
            splashRadius: 27,
          ),
        ],
      ),
    );
  }
}
