import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'package:passy/passy/dated_entry.dart';

import 'common.dart';

class DatedEntries<T extends DatedEntry<T>> {
  Iterable<T> get entries => _entryList;

  final File _file;
  late Map<DateTime, T> _entries;
  late List<T> _entryList;

  Encrypter _encrypter;
  set encrypter(Encrypter encrypter) => _encrypter = encrypter;

  void add(T entry) {
    _entries[entry.creationDate] = entry;
    _entryList.add(entry);
    _entryList.sort((a, b) => a.compareTo(b));
  }

  void remove(T entry) {
    _entries.remove(entry.creationDate);
    _entryList.remove(entry);
  }

  Future<void> save() =>
      _file.writeAsString(encrypt(jsonEncode(this), encrypter: _encrypter));
  void saveSync() =>
      _file.writeAsStringSync(encrypt(jsonEncode(this), encrypter: _encrypter));

  Map<String, dynamic> toJson() => _entries
      .map((key, value) => MapEntry(key.toIso8601String(), value.toJson()));

  DatedEntries(
    this._file, {
    required Encrypter encrypter,
  }) : _encrypter = encrypter {
    if (_file.existsSync()) {
      _entries =
          (jsonDecode(decrypt(_file.readAsStringSync(), encrypter: _encrypter))
                  as Map<String, dynamic>)
              .map((key, value) => MapEntry(DateTime.parse(key),
                  fromJsonMethods[T]!(value as Map<String, dynamic>) as T));
      _entryList = _entries.values.toList();
      _entryList.sort((a, b) => a.compareTo(b));
      return;
    }
    _entries = {};
    _entryList = [];
    _file.createSync();
    saveSync();
  }
}
