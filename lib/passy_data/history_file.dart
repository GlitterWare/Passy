import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/common.dart';

import 'encrypted_json_file.dart';
import 'history.dart';

class HistoryFile extends EncryptedJsonFile<History> {
  HistoryFile._(File file, Encrypter encrypter, {required History value})
      : super(file, encrypter, value: value);

  factory HistoryFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return HistoryFile._(file, encrypter,
          value: History.fromJson(
              decrypt(file.readAsStringSync(), encrypter: encrypter)));
    }
    file.createSync(recursive: true);
    HistoryFile _file = HistoryFile._(file, encrypter, value: History());
    _file.saveSync();
    return _file;
  }
}
