import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';

class ElevatedIconedButton extends StatelessWidget {
  final Widget? _leftIcon;
  final Widget _body;
  final Widget? _rightIcon;
  final void Function()? _onPressed;

  const ElevatedIconedButton({
    Key? key,
    Widget? leftIcon,
    required Widget body,
    Widget? rightIcon,
    void Function()? onPressed,
  })  : _leftIcon = leftIcon,
        _body = body,
        _rightIcon = rightIcon,
        _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: entryPadding,
        child: ElevatedButton(
            onPressed: _onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
            child: Padding(
              child: Row(
                children: [
                  if (_leftIcon != null)
                    Padding(
                      child: _leftIcon,
                      padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                    ),
                  Flexible(
                    child: _body,
                    fit: FlexFit.tight,
                  ),
                  if (_rightIcon != null) _rightIcon!,
                ],
              ),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            )),
      );
}
