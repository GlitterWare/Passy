import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/json_convertable.dart';
import 'package:universal_io/io.dart';

import 'dated_entry.dart';

import 'common.dart';

class DatedEntries<T extends DatedEntry<T>> implements JsonConvertable {
  Iterable<T> get entries => _entryList;
  final Map<DateTime, T> _entries;
  final List<T> _entryList;

  void sort() => _entryList.sort((a, b) => a.compareTo(b));

  void add(T entry) {
    _entries[entry.creationDate] = entry;
    _entryList.add(entry);
    sort();
  }

  void setEntry(T entry) {
    _entries[entry.creationDate] = entry;
    sort();
  }

  void remove(T entry) {
    _entries.remove(entry.creationDate);
    _entryList.remove(entry);
  }

  @override
  Map<String, dynamic> toJson() => _entries
      .map((key, value) => MapEntry(key.toIso8601String(), value.toJson()));

  factory DatedEntries.fromJson(String json) => DatedEntries(
      entries: (jsonDecode(json) as Map<String, dynamic>).map((key, value) =>
          MapEntry(DateTime.parse(key),
              fromJsonMethods[T]!(value as Map<String, dynamic>) as T)));

  factory DatedEntries.fromFile(File file, Encrypter encrypter) =>
      DatedEntries.fromJson(
          decrypt(file.readAsStringSync(), encrypter: encrypter));

  DatedEntries({Map<DateTime, T> entries = const {}})
      : _entries = entries,
        _entryList = entries.values.toList() {
    sort();
  }
}
