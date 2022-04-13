import 'custom_field.dart';
import 'entry_type.dart';
import 'passy_entry.dart';

abstract class PassyFormEntry<T> extends PassyEntry<T> {
  List<CustomField> customFields;
  List<String> tags;

  PassyFormEntry({
    required String key,
    List<CustomField>? customFields,
    List<String>? tags,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(key);
}

List<List> passyFormEntryToCSV<T extends PassyFormEntry>(
    T entry, {required Map<String, int> template}) {
  List<List> _csv = [
    [entryTypeFromType(entry.runtimeType).name]
  ];
  Map<String, dynamic> _json = entry.toJson();
  List<dynamic> _password = _csv[0];
  for (String key in template.keys) {
    _password.add(_json[key]);
  }
  for (CustomField field in entry.customFields) {
    _csv.addAll(field.toCSV());
  }
  if (entry.tags.isNotEmpty) {
    _csv.add(['tags'].followedBy(entry.tags).toList());
  }
  return _csv;
}
