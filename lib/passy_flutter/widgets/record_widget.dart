import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';

import 'widgets.dart';

class PassyRecord extends StatelessWidget {
  final String title;
  final TextStyle titleStyle;
  final String value;
  final bool obscureValue;
  final bool isPassword;
  final TextAlign valueAlign;

  PassyRecord({
    Key? key,
    required this.title,
    TextStyle? titleStyle,
    required this.value,
    this.obscureValue = false,
    this.isPassword = false,
    this.valueAlign = TextAlign.center,
  })  : titleStyle = titleStyle ??
            TextStyle(color: PassyTheme.lightContentSecondaryColor),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return DoubleActionButton(
      body: Column(
        children: [
          Text(
            title,
            style: titleStyle,
          ),
          FittedBox(
            child: Text(
              obscureValue ? '\u2022' * 6 : value,
              textAlign: valueAlign,
            ),
          ),
        ],
      ),
      icon: const Icon(Icons.copy),
      onButtonPressed: () => showDialog(
        context: context,
        builder: (_) => getRecordDialog(
            value: value, highlightSpecial: isPassword, textAlign: valueAlign),
      ),
      onActionPressed: () => Clipboard.setData(ClipboardData(text: value)),
    );
  }
}
