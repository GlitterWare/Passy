import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'dated_entries.dart';
import 'encrypted_json_file.dart';
import 'id_card.dart';

class IDCardsFile extends EncryptedJsonFile<DatedEntries<IDCard>> {
  IDCardsFile._(File file, Encrypter encrypter,
      {required DatedEntries<IDCard> value})
      : super(file, encrypter, value: value);

  factory IDCardsFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return IDCardsFile._(file, encrypter,
          value: DatedEntries<IDCard>.fromJson(
              decrypt(file.readAsStringSync(), encrypter: encrypter)));
    }
    file.createSync(recursive: true);
    IDCardsFile _file =
        IDCardsFile._(file, encrypter, value: DatedEntries<IDCard>());
    _file.saveSync();
    return _file;
  }
}
