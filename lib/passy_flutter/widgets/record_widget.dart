import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';

import 'widgets.dart';

class PassyRecord extends StatelessWidget {
  final String title;
  final String value;
  final bool obscureValue;
  final bool isPassword;
  final TextAlign valueAlign;

  const PassyRecord(
      {Key? key,
      required this.title,
      required this.value,
      this.obscureValue = false,
      this.isPassword = false,
      this.valueAlign = TextAlign.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DoubleActionButton(
      body: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: lightContentSecondaryColor),
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
