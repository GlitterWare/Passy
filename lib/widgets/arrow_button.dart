import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';

class ArrowButton extends StatelessWidget {
  final Widget _icon;
  final Widget _body;
  final void Function()? _onPressed;

  const ArrowButton({
    Key? key,
    required Widget icon,
    required Widget body,
    void Function()? onPressed,
  })  : _icon = icon,
        _body = body,
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
                  Padding(
                    child: _icon,
                    padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                  ),
                  Flexible(
                    child: _body,
                    fit: FlexFit.tight,
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded)
                ],
              ),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            )),
      );
}
