import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ButtonedTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final bool obscureText;
  final Widget? buttonIcon;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final void Function()? onPressed;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const ButtonedTextFormField({
    Key? key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.obscureText = false,
    this.buttonIcon,
    this.onTap,
    this.onChanged,
    this.onPressed,
    this.focusNode,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      key: key,
      children: [
        Flexible(
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            obscureText: obscureText,
            decoration: InputDecoration(labelText: labelText),
            onTap: onTap,
            onChanged: onChanged,
            focusNode: focusNode,
            inputFormatters: inputFormatters,
          ),
        ),
        FloatingActionButton(
          heroTag: null,
          onPressed: onPressed,
          child: buttonIcon,
        ),
      ],
    );
  }
}
