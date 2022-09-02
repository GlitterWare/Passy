export 'always_disabled_focus_node.dart';

import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import 'package:passy/passy_flutter/passy_theme.dart';

final bool isPlatformMobile = Platform.isAndroid || Platform.isIOS;
final bool isCameraSupported = isPlatformMobile;
final bool isBiometricStorageSupported = isPlatformMobile;

AlertDialog getRecordDialog(
    {required String value,
    bool highlightSpecial = false,
    TextAlign textAlign = TextAlign.center}) {
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
              color: PassyTheme.lightContentSecondaryColor,
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
  return AlertDialog(shape: PassyTheme.dialogShape, content: content);
}

String capitalize(String string) {
  if (string.isEmpty) return '';
  String _firstLetter = string[0].toUpperCase();
  if (string.length == 1) return _firstLetter;
  return '$_firstLetter${string.substring(1)}';
}
