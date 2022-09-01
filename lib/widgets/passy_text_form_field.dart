import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'passy_padding.dart';

class PassyTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType? keyboardType;
  final int? maxLines;
  final InputDecoration? decoration;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;

  const PassyTextFormField({
    Key? key,
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.maxLines = 1,
    this.decoration = const InputDecoration(),
    this.inputFormatters,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PassyPadding(TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: decoration,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
    ));
  }
}
