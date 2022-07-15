import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/theme.dart';

class TextFormFieldButtoned extends StatelessWidget {
  final TextEditingController? _controller;
  final String? _labelText;
  final bool _obscureText;
  final Widget? _buttonIcon;
  final void Function()? _onTap;
  final void Function(String)? _onChanged;
  final void Function()? _onPressed;
  final FocusNode? _focusNode;
  final List<TextInputFormatter>? _inputFormatters;

  const TextFormFieldButtoned({
    Key? key,
    TextEditingController? controller,
    String? labelText,
    bool obscureText = false,
    Widget? buttonIcon,
    void Function()? onTap,
    void Function(String)? onChanged,
    void Function()? onPressed,
    FocusNode? focusNode,
    List<TextInputFormatter>? inputFormatters,
  })  : _controller = controller,
        _labelText = labelText,
        _obscureText = obscureText,
        _onTap = onTap,
        _buttonIcon = buttonIcon,
        _onChanged = onChanged,
        _onPressed = onPressed,
        _focusNode = focusNode,
        _inputFormatters = inputFormatters,
        super(key: key);

  @override
  Widget build(BuildContext context) => Row(children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
                left: entryPadding.right,
                top: entryPadding.top,
                bottom: entryPadding.bottom),
            child: TextFormField(
              controller: _controller ?? TextEditingController(),
              obscureText: _obscureText,
              decoration: InputDecoration(labelText: _labelText),
              onTap: _onTap,
              onChanged: _onChanged,
              focusNode: _focusNode,
              inputFormatters: _inputFormatters,
            ),
          ),
        ),
        SizedBox(
          child: Padding(
            padding: EdgeInsets.only(right: entryPadding.right),
            child: FloatingActionButton(
              heroTag: null,
              onPressed: _onPressed,
              child: _buttonIcon,
            ),
          ),
        )
      ]);
}
