import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'csv_convertable.dart';
import 'encrypted_csv_file.dart';
import 'entry_type.dart';
import 'json_convertable.dart';
import 'passy_entry.dart';

class PassyEntries<T extends PassyEntry<T>>
    with JsonConvertable, CSVConvertable {
  final Map<String, T> _entries;
  Iterable<T> get entries => _entries.values;

  PassyEntries({Map<String, T>? entries}) : _entries = entries ?? {};

  PassyEntries.fromJson(Map<String, dynamic> json)
      : _entries = entriesFromJson(json);

  PassyEntries.fromCSV(List<List<dynamic>> csv)
      : _entries = entriesFromCSV(csv);

  T? getEntry(String key) => _entries[key];

  void setEntry(T entry) {
    _entries[entry.key] = entry;
  }

  void removeEntry(String key) => _entries.remove(key);

  @override
  Map<String, dynamic> toJson() =>
      _entries.map((key, value) => MapEntry(key, value.toJson()));

  @override
  List<List<dynamic>> toCSV() {
    List<List<dynamic>> csv = [];
    for (T entry in entries) {
      csv.add(entry.toCSV()[0]);
    }
    return csv;
  }

  static Map<String, T> entriesFromJson<T>(Map<String, dynamic> json) {
    T Function(Map<String, dynamic>) _fromJson =
        PassyEntry.fromJson(entryTypeFromType(T)!) as T Function(
            Map<String, dynamic>);
    return json.map<String, T>((key, value) =>
        MapEntry(key, _fromJson(value as Map<String, dynamic>)));
  }

  static Map<String, T> entriesFromCSV<T>(List<List<dynamic>> csv) {
    T Function(List<dynamic>) _fromCSV =
        PassyEntry.fromCSV(entryTypeFromType(T)!) as T Function(List<dynamic>);
    Map<String, T> _entries = {};
    for (List<dynamic> entry in csv) {
      _entries[entry[0]] = _fromCSV(entry);
    }
    return _entries;
  }

  static EncryptedCSVFile<PassyEntries<T>> fromFile<T extends PassyEntry<T>>(
    File file, {
    required Encrypter encrypter,
  }) =>
      EncryptedCSVFile<PassyEntries<T>>(
        file,
        encrypter: encrypter,
        constructor: () => PassyEntries<T>(),
        fromCSV: PassyEntries<T>.fromCSV,
      );
}
