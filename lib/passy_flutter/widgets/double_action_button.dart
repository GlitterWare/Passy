import 'package:flutter/material.dart';

class DoubleActionButton extends StatelessWidget {
  final Widget body;
  final Widget icon;
  final void Function()? onButtonPressed;
  final void Function()? onActionPressed;

  const DoubleActionButton({
    Key? key,
    required this.body,
    required this.icon,
    this.onButtonPressed,
    this.onActionPressed,
  }) : super(key: key);

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
      onPressed: onButtonPressed,
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: body,
          ),
          IconButton(
            onPressed: onActionPressed,
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            icon: icon,
            splashRadius: 27,
          ),
        ],
      ),
    );
  }
}
