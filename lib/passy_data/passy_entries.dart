import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'csv_convertable.dart';
import 'entry_type.dart';
import 'json_convertable.dart';
import 'passy_entry.dart';

class PassyEntries<T extends PassyEntry<T>>
    implements JsonConvertable, CSVConvertable {
  final Map<String, T> _entries;
  Iterable<T> get entries => _entries.values.toList();

  PassyEntries({Map<String, T>? entries}) : _entries = entries ?? {};

  factory PassyEntries.fromJson(Map<String, dynamic> json) {
    EntryType _type = entryTypeFromType(T);
    return PassyEntries(
        entries: json.map((key, value) => MapEntry(key,
            PassyEntry.fromJson(_type, value as Map<String, dynamic>) as T)));
  }

  factory PassyEntries.fromFile(File file, Encrypter encrypter) =>
      PassyEntries.fromJson(
          jsonDecode(decrypt(file.readAsStringSync(), encrypter: encrypter)));

  T? getEntry(String key) => _entries[key];

  void setEntry(T entry) {
    _entries[entry.key] = entry;
  }

  void removeEntry(String key) => _entries.remove(key);

  @override
  Map<String, dynamic> toJson() =>
      _entries.map((key, value) => MapEntry(key, value.toJson()));

  @override
  List<List<String>> toCSV() {
    // TODO: implement toCSV
    throw UnimplementedError();
  }
}
