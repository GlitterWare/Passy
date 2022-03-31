import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'dated_entries.dart';
import 'encrypted_json_file.dart';
import 'password.dart';

class PasswordsFile extends EncryptedJsonFile<DatedEntries<Password>> {
  PasswordsFile._(File file, Encrypter encrypter,
      {required DatedEntries<Password> value})
      : super(file, encrypter, value: value);

  factory PasswordsFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return PasswordsFile._(file, encrypter,
          value: DatedEntries<Password>.fromJson(
              decrypt(file.readAsStringSync(), encrypter: encrypter)));
    }
    file.createSync(recursive: true);
    PasswordsFile _file =
        PasswordsFile._(file, encrypter, value: DatedEntries<Password>());
    _file.saveSync();
    return _file;
  }
}
