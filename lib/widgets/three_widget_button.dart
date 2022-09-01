import 'package:flutter/material.dart';

class ThreeWidgetButton extends StatelessWidget {
  final Widget? _left;
  final Widget _center;
  final Widget? _right;
  final void Function()? _onPressed;

  const ThreeWidgetButton({
    Key? key,
    Widget? left,
    required Widget center,
    Widget? right,
    void Function()? onPressed,
  })  : _left = left,
        _center = center,
        _right = right,
        _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: key,
      onPressed: _onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      child: Padding(
        child: Row(
          children: [
            if (_left != null)
              Padding(
                child: _left,
                padding: const EdgeInsets.only(right: 30),
              ),
            Flexible(
              child: _center,
              fit: FlexFit.tight,
            ),
            if (_right != null) _right!,
          ],
        ),
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      ),
    );
  }
}
