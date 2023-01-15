import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/passy_entry.dart';
import 'package:passy/passy_data/saveable_file_base.dart';
import 'dart:io';

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
      Map<String, T> _entries = {};
      RandomAccessFile _file = file.openSync();
      bool eofReached = false;
      do {
        String? line = readLine(_file, onEOF: () => eofReached = true);
        if (line == null) continue;
        List<dynamic> _decoded1 = csvDecode(line);
        List<dynamic> _decoded2 = csvDecode(
            decrypt(_decoded1[1], encrypter: encrypter),
            recursive: true);
        _entries[_decoded1[0]] =
            (PassyEntry.fromCSV(entryTypeFromType(T)!)(_decoded2) as T);
      } while (eofReached == false);
      return PassyEntriesEncryptedCSVFile<T>(
        file,
        encrypter: encrypter,
        value: PassyEntries<T>(entries: _entries),
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

  String _encodeEntryForSaving(List<dynamic> _entry) {
    String _key = _entry[0];
    return '$_key,${encrypt(csvEncode(_entry), encrypter: _encrypter)}\n';
  }

  @override
  Future<void> save() async {
    await _file.writeAsString('');
    for (List _entry in value.toCSV()) {
      await _file.writeAsString(_encodeEntryForSaving(_entry),
          mode: FileMode.append);
    }
  }

  @override
  void saveSync() {
    _file.writeAsStringSync('');
    for (List _entry in value.toCSV()) {
      _file.writeAsStringSync(_encodeEntryForSaving(_entry),
          mode: FileMode.append);
    }
  }

  T? getEntry(String key) {
    RandomAccessFile _raf = _file.openSync();
    bool _eofReached = false;
    void _onEOF() => _eofReached = true;
    do {
      String? _key = readLine(_raf, lineDelimiter: ',', onEOF: _onEOF);
      if (_key == null) continue;
      if (_key == key) {
        if (_eofReached) return null;
        String? _entry = readLine(_raf, onEOF: _onEOF);
        if (_entry == null) return null;
        return PassyEntry.fromCSV(entryTypeFromType(T)!)(csvDecode(
            decrypt(_entry, encrypter: _encrypter),
            recursive: true)) as T;
      }
      skipLine(_raf, onEOF: _onEOF);
    } while (_eofReached == false);
    return null;
  }
}
