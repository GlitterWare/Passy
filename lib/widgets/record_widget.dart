import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/widgets/widgets.dart';

class PassyRecord extends StatelessWidget {
  final String _title;
  final String _value;
  final bool _obscureValue;
  final bool _isPassword;
  final TextAlign _valueAlign;

  const PassyRecord(
      {Key? key,
      required String title,
      required String value,
      bool obscureValue = false,
      bool isPassword = false,
      TextAlign valueAlign = TextAlign.center})
      : _title = title,
        _value = value,
        _obscureValue = obscureValue,
        _isPassword = isPassword,
        _valueAlign = valueAlign,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return DoubleActionButton(
      body: Column(
        children: [
          Text(
            _title,
            style: TextStyle(color: lightContentSecondaryColor),
          ),
          FittedBox(
            child: Text(
              _obscureValue ? '\u2022' * 6 : _value,
              textAlign: _valueAlign,
            ),
          ),
        ],
      ),
      icon: const Icon(Icons.copy),
      onButtonPressed: () => showDialog(
        context: context,
        builder: (_) => getRecordDialog(
            value: _value,
            highlightSpecial: _isPassword,
            textAlign: _valueAlign),
      ),
      onActionPressed: () => Clipboard.setData(ClipboardData(text: _value)),
    );
  }
}
