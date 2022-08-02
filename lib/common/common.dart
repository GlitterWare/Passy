import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import 'package:passy/passy_data/passy_data.dart';
import 'package:passy/screens/theme.dart';

late PassyData data;

final bool isPlatformMobile = Platform.isAndroid || Platform.isIOS;
final bool isCameraSupported = isPlatformMobile;
final bool isBiometricStorageSupported = isPlatformMobile;

AlertDialog getRecordDialog(
    {required String value, bool highlightSpecial = false}) {
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
              color: lightContentSecondaryColor,
            )));
      }
    }
    content = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(text: '', children: _children),
    );
  } else {
    content = Text(
      value,
      textAlign: TextAlign.center,
      style: const TextStyle(fontFamily: 'FiraCode'),
    );
  }
  return AlertDialog(shape: dialogShape, content: content);
}
