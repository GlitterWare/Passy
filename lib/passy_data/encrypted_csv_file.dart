import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/csv_convertable.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'saveable_file_base.dart';

class EncryptedCSVFile<T extends CSVConvertable> with SaveableFileBase {
  final T value;
  final File _file;
  Encrypter _encrypter;
  set encrypter(Encrypter encrypter) => _encrypter = encrypter;

  EncryptedCSVFile._(this._file,
      {required Encrypter encrypter, required this.value})
      : _encrypter = encrypter;

  factory EncryptedCSVFile(
    File file, {
    required Encrypter encrypter,
    required T Function() constructor,
    required T Function(List<List> csv) fromCSV,
  }) {
    T _value;
    if (file.existsSync()) {
      _value = fromCSV(csvDecode(
          decrypt(file.readAsStringSync(), encrypter: encrypter),
          recursive: true));
    } else {
      _value = constructor();
    }
    return EncryptedCSVFile._(file, encrypter: encrypter, value: _value);
  }

  @override
  Future<void> save() => _file
      .writeAsString(encrypt(csvEncode(value.toCSV()), encrypter: _encrypter));

  @override
  void saveSync() => _file.writeAsStringSync(
      encrypt(csvEncode(value.toCSV()), encrypter: _encrypter));
}
