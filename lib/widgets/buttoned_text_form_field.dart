import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/theme.dart';

class ButtonedTextFormField extends StatelessWidget {
  final TextEditingController? _controller;
  final String? _initialValue;
  final String? _labelText;
  final bool _obscureText;
  final Widget? _buttonIcon;
  final void Function()? _onTap;
  final void Function(String)? _onChanged;
  final void Function()? _onPressed;
  final FocusNode? _focusNode;
  final List<TextInputFormatter>? _inputFormatters;

  const ButtonedTextFormField({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    String? labelText,
    bool obscureText = false,
    Widget? buttonIcon,
    void Function()? onTap,
    void Function(String)? onChanged,
    void Function()? onPressed,
    FocusNode? focusNode,
    List<TextInputFormatter>? inputFormatters,
  })  : _controller = controller,
        _initialValue = initialValue,
        _labelText = labelText,
        _obscureText = obscureText,
        _buttonIcon = buttonIcon,
        _onTap = onTap,
        _onChanged = onChanged,
        _onPressed = onPressed,
        _focusNode = focusNode,
        _inputFormatters = inputFormatters,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      key: key,
      children: [
        Flexible(
          child: TextFormField(
            controller: _controller,
            initialValue: _initialValue,
            obscureText: _obscureText,
            decoration: InputDecoration(labelText: _labelText),
            onTap: _onTap,
            onChanged: _onChanged,
            focusNode: _focusNode,
            inputFormatters: _inputFormatters,
          ),
        ),
        SizedBox(
          child: FloatingActionButton(
            heroTag: null,
            onPressed: _onPressed,
            child: _buttonIcon,
          ),
        ),
      ],
    );
  }
}
