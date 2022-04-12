import 'package:csv/csv.dart';
import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/passy_entry.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'passy_entries.dart';
import 'saveable_file_base.dart';

class PassyEntriesFile<T extends PassyEntry<T>> implements SaveableFileBase {
  final PassyEntries<T> value;
  final File _file;
  Encrypter _encrypter;
  set encrypter(Encrypter encrypter) => _encrypter = encrypter;

  PassyEntriesFile._(this._file,
      {required Encrypter encrypter, required this.value})
      : _encrypter = encrypter;

  factory PassyEntriesFile(File file, {required Encrypter encrypter}) {
    PassyEntries<T> _value;
    if (file.existsSync()) {
      _value = PassyEntries<T>.fromCSV(file.readAsStringSync());
    } else {
      _value = PassyEntries<T>();
    }
    return PassyEntriesFile._(file, encrypter: encrypter, value: _value);
  }

  @override
  Future<void> save() => _file.writeAsString(encrypt(
      const ListToCsvConverter(textDelimiter: '').convert(value.toCSV()),
      encrypter: _encrypter));
  @override
  void saveSync() => _file.writeAsStringSync(encrypt(
      const ListToCsvConverter(textDelimiter: '').convert(value.toCSV()),
      encrypter: _encrypter));
}
