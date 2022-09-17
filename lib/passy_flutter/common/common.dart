export 'always_disabled_focus_node.dart';

import 'package:flutter/material.dart';
import 'package:passy_website/passy_flutter/passy_theme.dart';

String capitalize(String string) {
  if (string.isEmpty) return '';
  String _firstLetter = string[0].toUpperCase();
  if (string.length == 1) return _firstLetter;
  return '$_firstLetter${string.substring(1)}';
}

String beautifyCardNumber(String cardNumber) {
  if (cardNumber.isEmpty) {
    return '';
  }
  String _value = cardNumber.trim();
  cardNumber = _value[0];
  for (int i = 1; i < _value.length; i++) {
    if (i % 4 == 0) cardNumber += ' ';
    cardNumber += _value[i];
  }
  return cardNumber;
}

int alphabeticalCompare(String a, String b) =>
    a.toLowerCase().compareTo(b.toLowerCase());

Future<DateTime?> showPassyDatePicker(
    {required BuildContext context,
    required DateTime date,
    ColorScheme colorScheme = PassyTheme.datePickerColorScheme}) {
  return showDatePicker(
    context: context,
    initialDate: date,
    firstDate: DateTime.utc(0, 04, 20),
    lastDate: DateTime.utc(275760, 09, 13),
    builder: (context, w) => Theme(
      data: ThemeData(colorScheme: colorScheme),
      child: w!,
    ),
  );
}
