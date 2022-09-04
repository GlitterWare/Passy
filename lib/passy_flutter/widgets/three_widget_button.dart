import 'package:flutter/material.dart';

class ThreeWidgetButton extends StatelessWidget {
  final Widget? left;
  final Widget center;
  final Widget? right;
  final void Function()? onPressed;

  const ThreeWidgetButton({
    Key? key,
    this.left,
    required this.center,
    this.right,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: key,
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      child: Padding(
        child: Row(
          children: [
            if (left != null) left!,
            Flexible(
              child: center,
              fit: FlexFit.tight,
            ),
            if (right != null) right!,
          ],
        ),
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      ),
    );
  }
}
