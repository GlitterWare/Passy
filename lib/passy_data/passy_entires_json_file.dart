import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/passy_entries_encrypted_csv_file.dart';
import 'package:passy/passy_data/passy_entry.dart';
import 'package:passy/passy_data/saveable_file_base.dart';
import 'dart:io';

import 'passy_entries.dart';

class PassyEntriesJSONFile<T extends PassyEntry<T>> with SaveableFileBase {
  final File _file;
  final PassyEntries<T> value;

  PassyEntriesJSONFile(
    this._file, {
    required this.value,
  });

  factory PassyEntriesJSONFile.fromFile(File file) {
    if (file.existsSync()) {
      return PassyEntriesJSONFile<T>(
        file,
        value: PassyEntries<T>.fromJson(jsonDecode(file.readAsStringSync())),
      );
    }
    file.createSync(recursive: true);
    PassyEntriesJSONFile<T> _file =
        PassyEntriesJSONFile<T>(file, value: PassyEntries<T>());
    _file.saveSync();
    return _file;
  }

  @override
  Future<void> save() => _file.writeAsString(jsonEncode(value.toJson()));

  @override
  void saveSync() => _file.writeAsStringSync(jsonEncode(value.toJson()));

  PassyEntriesEncryptedCSVFile<T> toPassyEntriesEncryptedCSVFile(
          Encrypter encrypter) =>
      PassyEntriesEncryptedCSVFile<T>(_file, encrypter: encrypter);
}
