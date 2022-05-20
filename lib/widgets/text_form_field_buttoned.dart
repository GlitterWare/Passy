import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/theme.dart';

class TextFormFieldButtoned extends StatefulWidget {
  final TextEditingController? _controller;
  final String? _labelText;
  final Widget? _buttonIcon;
  final void Function(String)? _onChanged;
  final void Function()? _onPressed;
  final List<TextInputFormatter>? _inputFormatters;

  const TextFormFieldButtoned({
    TextEditingController? controller,
    Key? key,
    String? labelText,
    Widget? buttonIcon,
    void Function(String)? onChanged,
    void Function()? onPressed,
    List<TextInputFormatter>? inputFormatters,
  })  : _buttonIcon = buttonIcon,
        _controller = controller,
        _labelText = labelText,
        _onChanged = onChanged,
        _onPressed = onPressed,
        _inputFormatters = inputFormatters,
        super(key: key);

  @override
  State<StatefulWidget> createState() =>
      // ignore: no_logic_in_create_state
      _TextFormFieldButtoned(
        controller: _controller,
        labelText: _labelText,
        buttonIcon: _buttonIcon,
        onChanged: _onChanged,
        onPressed: _onPressed,
        inputFormatters: _inputFormatters,
      );
}

class _TextFormFieldButtoned extends State<TextFormFieldButtoned> {
  final TextEditingController? _controller;
  final String? _labelText;
  final Widget? _buttonIcon;
  final void Function(String)? _onChanged;
  final void Function()? _onPressed;
  final List<TextInputFormatter>? _inputFormatters;

  _TextFormFieldButtoned({
    TextEditingController? controller,
    String? labelText,
    Widget? buttonIcon,
    void Function(String)? onChanged,
    void Function()? onPressed,
    List<TextInputFormatter>? inputFormatters,
  })  : _controller = controller,
        _labelText = labelText,
        _buttonIcon = buttonIcon,
        _onChanged = onChanged,
        _onPressed = onPressed,
        _inputFormatters = inputFormatters;

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
              decoration: InputDecoration(labelText: _labelText),
              onChanged: _onChanged,
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
