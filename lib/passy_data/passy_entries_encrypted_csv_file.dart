import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/passy_entry.dart';
import 'package:passy/passy_data/saveable_file_base.dart';
import 'package:universal_io/io.dart';

import 'passy_entries.dart';

class PassyEntriesEncryptedCSVFile<T extends PassyEntry<T>>
    with SaveableFileBase {
  final File _file;
  final PassyEntries<T> value;
  Encrypter _encrypter;
  set encrypter(Encrypter encrypter) => _encrypter = encrypter;

  PassyEntriesEncryptedCSVFile(
    this._file, {
    required Encrypter encrypter,
    required this.value,
  }) : _encrypter = encrypter;

  factory PassyEntriesEncryptedCSVFile.fromFile(
    File file, {
    required Encrypter encrypter,
  }) {
    if (file.existsSync()) {
      String _decrypted =
          decrypt(file.readAsStringSync(), encrypter: encrypter);
      List<String> _split = _decrypted.split('\n');
      List<List> _decoded = [];
      for (String s in _split) {
        if (s == '') continue;
        _decoded.add(csvDecode(s, recursive: true));
      }
      return PassyEntriesEncryptedCSVFile<T>(
        file,
        encrypter: encrypter,
        value: PassyEntries<T>.fromCSV(_decoded),
      );
    }
    file.createSync(recursive: true);
    PassyEntriesEncryptedCSVFile<T> _file = PassyEntriesEncryptedCSVFile<T>(
        file,
        encrypter: encrypter,
        value: PassyEntries<T>());
    _file.saveSync();
    return _file;
  }

  String _save() {
    String _result = '';
    for (List _value in value.toCSV()) {
      _result += csvEncode(_value) + '\n';
    }
    return _result == '' ? '' : encrypt(_result, encrypter: _encrypter);
  }

  @override
  Future<void> save() => _file.writeAsString(_save());

  @override
  void saveSync() => _file.writeAsStringSync(_save());
}
