import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/json_convertable.dart';
import 'package:universal_io/io.dart';

import 'dated_entry.dart';

import 'common.dart';

class DatedEntries<T extends DatedEntry<T>> implements JsonConvertable {
  Iterable<T> get entries => _entryList;
  final Map<String, T> _entries;
  final List<T> _entryList;

  void sort() => _entryList.sort((a, b) => a.compareTo(b));

  void addEntry(T entry) {
    _entries[entry.creationDate] = entry;
    _entryList.add(entry);
    sort();
  }

  T? getEntry(String key) => _entries[key];

  void setEntry(T entry) {
    if (!_entries.containsKey(entry.creationDate)) {
      _entryList.add(entry);
    }
    _entries[entry.creationDate] = entry;
    sort();
  }

  void remove(String key) {
    DatedEntry<T> _entry = _entries[key]!;
    _entries.remove(key);
    _entryList.remove(_entry);
  }

  @override
  Map<String, dynamic> toJson() =>
      _entries.map((key, value) => MapEntry(key, value.toJson()));

  factory DatedEntries.fromJson(Map<String, dynamic> json) => DatedEntries(
      entries: json.map((key, value) => MapEntry(
          key, fromJsonMethods[T]!(value as Map<String, dynamic>) as T)));

  factory DatedEntries.fromFile(File file, Encrypter encrypter) =>
      DatedEntries.fromJson(
          jsonDecode(decrypt(file.readAsStringSync(), encrypter: encrypter)));

  DatedEntries({Map<String, T> entries = const {}})
      : _entries = entries,
        _entryList = entries.values.toList() {
    sort();
  }
}
