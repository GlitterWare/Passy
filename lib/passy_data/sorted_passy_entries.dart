import 'package:passy/passy_data/passy_entries.dart';
import 'package:passy/passy_data/passy_entry.dart';

class SortedPassyEntries<T extends PassyEntry<T>> extends PassyEntries<T> {
  final List<T> _entryList;

  @override
  Iterable<T> get entries => _entryList;

  SortedPassyEntries({Map<String, T>? entries})
      : _entryList = entries?.values.toList() ?? [],
        super(entries: entries) {
    sort();
  }

  void sort() => _entryList.sort((a, b) => a.compareTo(b));

  @override
  void setEntry(T entry) {
    if (!_entryList.contains(entry)) {
      _entryList.add(entry);
      sort();
    }
    super.setEntry(entry);
  }

  @override
  void removeEntry(String key) {
    super.removeEntry(key);
    _entryList.remove(getEntry(key)!);
  }
}
