import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/screens/common.dart';

import 'widgets.dart';

class RecordButton extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final String value;
  final bool obscureValue;
  final bool isPassword;
  final TextAlign valueAlign;
  final Widget? left;

  const RecordButton({
    Key? key,
    required this.title,
    this.titleStyle,
    required this.value,
    this.obscureValue = false,
    this.isPassword = false,
    this.valueAlign = TextAlign.center,
    this.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThreeWidgetButton(
      left: left,
      center: Column(
        children: [
          Text(
            title,
            style: titleStyle ??
                TextStyle(
                    color:
                        PassyTheme.of(context).highlightContentSecondaryColor,
                    height: 0.94),
          ),
          Text(
            obscureValue ? '\u2022' * 6 : value,
            textAlign: valueAlign,
          ),
        ],
      ),
      onPressed: () => showDialog(
        context: context,
        builder: (_) => RecordDialog(
            value: value, highlightSpecial: isPassword, textAlign: valueAlign),
      ),
      right: CircleAvatar(
        backgroundColor: PassyTheme.of(context).highlightContentColor,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.copy_rounded),
          tooltip: localizations.copy,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            showSnackBar(
              message: '$title ${localizations.copied.toLowerCase()}',
              icon: const Icon(Icons.copy_rounded),
            );
          },
        ),
      ),
    );
  }
}
