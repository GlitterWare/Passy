import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';

class TextFormFieldButtoned extends StatefulWidget {
  final String? _labelText;
  final void Function(String)? _onChanged;
  final void Function()? _onPressed;

  const TextFormFieldButtoned({
    Key? key,
    String? labelText,
    void Function(String)? onChanged,
    void Function()? onPressed,
  })  : _labelText = labelText,
        _onChanged = onChanged,
        _onPressed = onPressed,
        super(key: key);

  @override
  State<StatefulWidget> createState() =>
      // ignore: no_logic_in_create_state
      _TextFormFieldButtoned(
          labelText: _labelText, onChanged: _onChanged, onPressed: _onPressed);
}

class _TextFormFieldButtoned extends State<TextFormFieldButtoned> {
  final String? _labelText;
  final void Function(String)? _onChanged;
  final void Function()? _onPressed;

  _TextFormFieldButtoned({
    String? labelText,
    void Function(String)? onChanged,
    void Function()? onPressed,
  })  : _labelText = labelText,
        _onChanged = onChanged,
        _onPressed = onPressed;

  @override
  Widget build(BuildContext context) => Row(children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
                left: entryPadding.right,
                top: entryPadding.top,
                bottom: entryPadding.bottom),
            child: TextFormField(
              controller: TextEditingController(),
              decoration: InputDecoration(labelText: _labelText),
              onChanged: _onChanged,
            ),
          ),
        ),
        SizedBox(
          child: Padding(
            padding: EdgeInsets.only(right: entryPadding.right),
            child: FloatingActionButton(
              onPressed: _onPressed,
              child: const Icon(Icons.delete_outline_rounded),
            ),
          ),
        )
      ]);
}
