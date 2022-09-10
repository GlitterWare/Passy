export 'always_disabled_focus_node.dart';

import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

String capitalize(String string) {
  if (string.isEmpty) return '';
  String _firstLetter = string[0].toUpperCase();
  if (string.length == 1) return _firstLetter;
  return '$_firstLetter${string.substring(1)}';
}

CardType cardTypeFromCreditCardType(CreditCardType cardType) {
  switch (cardType) {
    case CreditCardType.visa:
      return CardType.visa;
    case CreditCardType.mastercard:
      return CardType.mastercard;
    case CreditCardType.amex:
      return CardType.americanExpress;
    case CreditCardType.discover:
      return CardType.discover;
    default:
      return CardType.otherBrand;
  }
}

CardType cardTypeFromNumber(String number) =>
    cardTypeFromCreditCardType(detectCCType(number));

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

String dateToString(DateTime date) {
  return date.day.toString() +
      '/' +
      date.month.toString() +
      '/' +
      date.year.toString();
}

DateTime stringToDate(String value) {
  if (value == '') return DateTime.now();
  List<String> _dateSplit = value.split('/');
  if (_dateSplit.length == 3) return DateTime.now();
  return DateTime(
    int.parse(_dateSplit[2]),
    int.parse(_dateSplit[1]),
    int.parse(_dateSplit[0]),
  );
}

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
