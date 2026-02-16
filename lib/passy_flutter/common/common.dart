export 'always_disabled_focus_node.dart';

import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:credit_card_type_detector/constants.dart';
import 'package:credit_card_type_detector/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

class CardAssetPaths {
  const CardAssetPaths._();

  static const String visa = 'icons/visa.png';
  static const String rupay = 'icons/rupay.png';
  static const String mastercard = 'icons/mastercard.png';
  static const String americanExpress = 'icons/amex.png';
  static const String unionpay = 'icons/unionpay.png';
  static const String discover = 'icons/discover.png';
  static const String elo = 'icons/elo.png';
  static const String hipercard = 'icons/hipercard.png';
  static const String chip = 'icons/chip.png';
}

const Map<CardType, String> cardTypeIconAsset = <CardType, String>{
  CardType.visa: CardAssetPaths.visa,
  CardType.rupay: CardAssetPaths.rupay,
  CardType.americanExpress: CardAssetPaths.americanExpress,
  CardType.mastercard: CardAssetPaths.mastercard,
  CardType.unionpay: CardAssetPaths.unionpay,
  CardType.discover: CardAssetPaths.discover,
  CardType.elo: CardAssetPaths.elo,
  CardType.hipercard: CardAssetPaths.hipercard,
};

String capitalize(String string) {
  if (string.isEmpty) return '';
  String _firstLetter = string[0].toUpperCase();
  if (string.length == 1) return _firstLetter;
  return '$_firstLetter${string.substring(1)}';
}

CardType cardTypeFromCreditCardType(List<CreditCardType> cardTypes) {
  if (cardTypes.isEmpty) return CardType.otherBrand;
  final cardType = cardTypes.first;
  if (cardType.type == TYPE_VISA) {
    return CardType.visa;
  } else if (cardType.type == TYPE_MASTERCARD) {
    return CardType.mastercard;
  } else if (cardType.type == TYPE_AMEX) {
    return CardType.americanExpress;
  } else if (cardType.type == TYPE_DISCOVER) {
    return CardType.discover;
  } else {
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
  if (_dateSplit.length < 2) return DateTime.now();
  if (_dateSplit.length < 3) _dateSplit.insert(0, '01');
  int? yy = int.tryParse(_dateSplit[2]);
  if (yy == null) return DateTime.now();
  int? mm = int.tryParse(_dateSplit[1]);
  if (mm == null) return DateTime.now();
  int? dd = int.tryParse(_dateSplit[0]);
  if (dd == null) return DateTime.now();
  return DateTime(yy, mm, dd);
}

Future<DateTime?> showPassyDatePicker({
  required BuildContext context,
  required DateTime date,
  ColorScheme? colorScheme,
}) {
  return showDatePicker(
    context: context,
    initialDate: date,
    firstDate: DateTime.utc(0, 04, 20),
    lastDate: DateTime.utc(275760, 09, 13),
    builder: (context, w) => Theme(
      data: ThemeData(
          colorScheme:
              colorScheme ?? PassyTheme.of(context).datePickerColorScheme),
      child: w!,
    ),
  );
}

Widget getCardTypeImage(CardType? cardType) {
  if (cardType == CardType.otherBrand) {
    return SvgPicture.asset(
      'assets/images/logo_circle.svg',
      colorFilter: const ColorFilter.mode(Colors.purple, BlendMode.srcIn),
      width: 50,
    );
  }

  return Image.asset(
    cardTypeIconAsset[cardType]!,
    height: 48,
    width: 48,
    package: 'flutter_credit_card',
  );
}

Future<bool> confirmUrlStatusCode(String url, {int statusCode = 200}) async {
  try {
    Uri uri = Uri.parse(url);
    http.Response response = await http.get(uri);
    if (response.statusCode == statusCode) return true;
  } catch (_) {}
  return false;
}

const List<String> prohibitedFileNames = [
  '',
  '.',
  '..',
  'CON',
  'PRN',
  'AUX',
  'CLOCK\$',
  'NUL',
  'COM1',
  'COM2',
  'COM3',
  'COM4',
  'COM5',
  'COM6',
  'COM7',
  'COM8',
  'COM9',
  'LPT1',
  'LPT2',
  'LPT3',
  'LPT4',
  'LPT5',
  'LPT6',
  'LPT7',
  'LPT8',
  'LPT9',
];
