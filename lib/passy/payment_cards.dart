import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'payment_card.dart';

class PaymentCards {
  final List<PaymentCard> paymentCards;
  final Encrypter _encrypter;
  final File _file;

  Future<void> save() => _file
      .writeAsString(encrypt(jsonEncode(paymentCards), encrypter: _encrypter));
  void saveSync() => _file.writeAsStringSync(
      encrypt(jsonEncode(paymentCards), encrypter: _encrypter));

  PaymentCards._(
    File file, {
    required Encrypter encrypter,
    required this.paymentCards,
  })  : _file = file,
        _encrypter = encrypter;

  factory PaymentCards(File file, {required Encrypter encrypter}) {
    if (file.existsSync()) {
      List<dynamic> _json =
          jsonDecode(decrypt(file.readAsStringSync(), encrypter: encrypter));
      return PaymentCards._(
        file,
        encrypter: encrypter,
        paymentCards: _json
            .map((e) => PaymentCard.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    file.createSync();
    PaymentCards _paymentCards = PaymentCards._(
      file,
      encrypter: encrypter,
      paymentCards: [],
    );
    _paymentCards.saveSync();
    return _paymentCards;
  }
}
