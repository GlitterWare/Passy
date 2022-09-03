import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class RecordDialog extends StatelessWidget {
  final String value;
  final bool highlightSpecial;
  final TextAlign textAlign;
  final ShapeBorder? shape;
  final Color? specialColor;

  const RecordDialog({
    Key? key,
    required this.value,
    this.highlightSpecial = false,
    this.textAlign = TextAlign.center,
    this.shape = PassyTheme.dialogShape,
    this.specialColor = PassyTheme.lightContentSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (highlightSpecial) {
      List<InlineSpan> _children = [];
      Iterator<String> _iterator = value.characters.iterator;
      while (_iterator.moveNext()) {
        if (_iterator.current.contains(RegExp(r'[a-z]|[A-Z]'))) {
          _children.add(TextSpan(
              text: _iterator.current,
              style: const TextStyle(fontFamily: 'FiraCode')));
        } else {
          _children.add(TextSpan(
              text: _iterator.current,
              style: TextStyle(
                fontFamily: 'FiraCode',
                color: specialColor,
              )));
        }
      }
      content = SelectableText.rich(
        TextSpan(text: '', children: _children),
        textAlign: textAlign,
      );
    } else {
      content = SelectableText(
        value,
        textAlign: textAlign,
        style: const TextStyle(fontFamily: 'FiraCode'),
      );
    }
    return AlertDialog(shape: shape, content: content);
  }
}
