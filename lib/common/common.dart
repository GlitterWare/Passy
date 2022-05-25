import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import 'package:passy/passy_data/passy_data.dart';
import 'package:passy/widgets/passy_back_button.dart';

import 'theme.dart';

late PassyData data;

final bool cameraSupported = Platform.isAndroid || Platform.isIOS;

AppBar getEditScreenAppBar(
  BuildContext context, {
  required String title,
  required void Function()? onSave,
  bool isNew = false,
}) =>
    AppBar(
      leading: PassyBackButton(onPressed: () => Navigator.pop(context)),
      title: isNew
          ? Center(child: Text('Add $title'))
          : Center(child: Text('Edit $title')),
      actions: [
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          onPressed: onSave,
          icon: isNew
              ? const Icon(Icons.add_rounded)
              : const Icon(Icons.check_rounded),
        ),
      ],
    );

AlertDialog getRecordDialog(
    {required String value, bool highlightSpecial = false}) {
  Widget content;
  if (highlightSpecial) {
    List<InlineSpan> _children = [];
    Iterator<String> _iterator = value.characters.iterator;
    while (_iterator.moveNext()) {
      if (_iterator.current.contains(RegExp(r'([a-z]|[A-Z])'))) {
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
