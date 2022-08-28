import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'passy_padding.dart';

class PassyTextFormField extends StatelessWidget {
  final TextEditingController? _controller;
  final TextInputType? _keyboardType;
  final int? _maxLines;
  final InputDecoration? _decoration;
  final List<TextInputFormatter>? _inputFormatters;
  final void Function(String)? _onChanged;

  const PassyTextFormField({
    Key? key,
    TextEditingController? controller,
    TextInputType? keyboardType,
    int? maxLines = 1,
    InputDecoration? decoration = const InputDecoration(),
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  })  : _controller = controller,
        _keyboardType = keyboardType,
        _maxLines = maxLines,
        _decoration = decoration,
        _inputFormatters = inputFormatters,
        _onChanged = onChanged,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PassyPadding(TextFormField(
      controller: _controller,
      keyboardType: _keyboardType,
      maxLines: _maxLines,
      decoration: _decoration,
      onChanged: _onChanged,
      inputFormatters: _inputFormatters,
    ));
  }
}
