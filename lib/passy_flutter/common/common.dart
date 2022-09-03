export 'always_disabled_focus_node.dart';

import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

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
