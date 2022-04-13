import 'csv_convertable.dart';
import 'entry_type.dart';
import 'json_convertable.dart';
import 'passy_entry.dart';

class PassyEntries<T extends PassyEntry<T>>
    implements JsonConvertable, CSVConvertable {
  final Map<String, T> _entries;
  Iterable<T> get entries => _entries.values;

  PassyEntries({Map<String, T>? entries}) : _entries = entries ?? {};

  factory PassyEntries.fromJson(Map<String, dynamic> json) {
    EntryType _type = entryTypeFromType(T);
    return PassyEntries(
        entries: json.map((key, value) => MapEntry(key,
            PassyEntry.fromJson(_type, value as Map<String, dynamic>) as T)));
  }

  factory PassyEntries.fromCSV(List<List<dynamic>> csv) {
    EntryType _type = entryTypeFromType(T);
    List<List<dynamic>> _entryCSV = [];
    Map<String, T> _entries = {};

    // TODO: read schemas at the start of the csv

    void _decodeEntry() {
      if (_entryCSV.isEmpty) return;
      T _entry = PassyEntry.fromCSV(_type, _entryCSV) as T;
      _entries[_entry.key] = _entry;
    }

    for (List<dynamic> line in csv) {
      if (line.isEmpty) {
        _decodeEntry();
        _entryCSV = [];
        continue;
      }
      _entryCSV.add(line);
    }
    _decodeEntry();

    return PassyEntries(entries: _entries);
  }

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
    // TODO: write schemas at the start of the csv

    List<List<dynamic>> csv = [];
    for (T entry in entries) {
      csv.addAll(entry.toCSV());
      csv.add([]);
    }
    if (csv.isNotEmpty) csv.removeLast();
    return csv;
  }
}
