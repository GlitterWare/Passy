import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'dated_entries.dart';
import 'encrypted_json_file.dart';
import 'payment_card.dart';

class PaymentCardsFile extends EncryptedJsonFile<DatedEntries<PaymentCard>> {
  PaymentCardsFile._(File file, Encrypter encrypter,
      {required DatedEntries<PaymentCard> value})
      : super(file, encrypter, value: value);

  factory PaymentCardsFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return PaymentCardsFile._(file, encrypter,
          value: DatedEntries<PaymentCard>.fromJson(
              decrypt(file.readAsStringSync(), encrypter: encrypter)));
    }
    file.createSync(recursive: true);
    PaymentCardsFile _file =
        PaymentCardsFile._(file, encrypter, value: DatedEntries<PaymentCard>());
    _file.saveSync();
    return _file;
  }
}
