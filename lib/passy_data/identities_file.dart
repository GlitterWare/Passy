import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'dated_entries.dart';
import 'encrypted_json_file.dart';
import 'identity.dart';

class IdentitiesFile extends EncryptedJsonFile<DatedEntries<Identity>> {
  IdentitiesFile._(File file, Encrypter encrypter,
      {required DatedEntries<Identity> value})
      : super(file, encrypter, value: value);

  factory IdentitiesFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return IdentitiesFile._(file, encrypter,
          value: DatedEntries<Identity>.fromJson(
              decrypt(file.readAsStringSync(), encrypter: encrypter)));
    }
    IdentitiesFile _file =
        IdentitiesFile._(file, encrypter, value: DatedEntries<Identity>());
    _file.saveSync();
    return _file;
  }
}
