import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';

class RecordDialog extends StatefulWidget {
  final String value;
  final List<String>? oldValues;
  final bool highlightSpecial;
  final TextAlign textAlign;
  final ShapeBorder? shape;
  final Color? specialColor;

  const RecordDialog({
    Key? key,
    required this.value,
    this.oldValues,
    this.highlightSpecial = false,
    this.textAlign = TextAlign.center,
    this.shape = PassyTheme.dialogShape,
    this.specialColor,
  }) : super(key: key);

  @override
  _RecordDialog createState() => _RecordDialog();
}

class _RecordDialog extends State<RecordDialog> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (widget.highlightSpecial) {
      List<InlineSpan> _children = [];
      Iterator<String> _iterator = _index == 0
          ? widget.value.characters.iterator
          : widget.oldValues![_index - 1].characters.iterator;
      while (_iterator.moveNext()) {
        if (_iterator.current.contains(RegExp(r'[a-z]|[A-Z]'))) {
          _children.add(TextSpan(
              text: _iterator.current,
              style: const TextStyle(fontFamily: 'FiraCode')));
        } else {
          _children.add(TextSpan(
              text: _iterator.current,
              style: TextStyle(
                fontFamily: _iterator.current == '&' ? null : 'FiraCode',
                fontWeight: _iterator.current == '&' ? FontWeight.bold : null,
                color: widget.specialColor ??
                    PassyTheme.of(context).highlightContentSecondaryColor,
              )));
        }
      }
      content = SelectableText.rich(
        TextSpan(text: '', children: _children),
        textAlign: widget.textAlign,
      );
    } else {
      content = SelectableText(
        _index == 0 ? widget.value : widget.oldValues![_index - 1],
        textAlign: widget.textAlign,
        style: const TextStyle(fontFamily: 'FiraCode'),
      );
    }
    return AlertDialog(
        shape: widget.shape,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.restore_rounded),
              tooltip: widget.oldValues == null
                  ? null
                  : widget.oldValues!.isEmpty
                      ? null
                      : localizations.restore,
              disabledColor: Colors.transparent,
              onPressed: widget.oldValues == null
                  ? null
                  : widget.oldValues!.isEmpty
                      ? null
                      : () => setState(() => _index =
                          _index == widget.oldValues!.length ? 0 : _index + 1),
            ),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.only(
                        left: PassyTheme.of(context).passyPadding.left,
                        right: PassyTheme.of(context).passyPadding.right),
                    child: content)),
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.copy_rounded),
              tooltip: localizations.copy,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _index == 0 ? widget.value : widget.oldValues![_index - 1]));
                showSnackBar(
                  message: localizations.copied,
                  icon: const Icon(Icons.copy_rounded),
                );
              },
            ),
          ],
        ));
  }
}
