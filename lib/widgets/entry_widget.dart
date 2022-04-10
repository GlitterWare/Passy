import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:passy/screens/passwords_screen.dart';

class EntryWidget extends StatelessWidget {
  final Widget _icon;
  final Widget _child;
  final VoidCallback? _onIconPressed;
  final VoidCallback? _onPressed;

  const EntryWidget({
    Key? key,
    required Widget icon,
    required Widget child,
    VoidCallback? onPressed,
    VoidCallback? onIconPressed,
  })  : _icon = icon,
        _child = child,
        _onPressed = onPressed,
        _onIconPressed = onIconPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
        child: ElevatedButton(
          onPressed: _onPressed,
          child: Padding(
            child: Row(
              children: [
                Padding(
                  child: _icon,
                  padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                ),
                Flexible(
                  child: _child,
                  fit: FlexFit.tight,
                ),
                const Icon(Icons.arrow_forward_ios_rounded)
              ],
            ),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          ),
          style: ElevatedButton.styleFrom(
              primary: Colors.white, onPrimary: Colors.black),
        ),
      );
}
