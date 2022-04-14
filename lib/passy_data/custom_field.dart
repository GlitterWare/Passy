import 'csv_convertable.dart';
import 'json_convertable.dart';

enum FieldType { text, password, date, number }

FieldType? fieldTypeFromName(String name) {
  switch (name) {
    case 'text':
      return FieldType.text;
    case 'password':
      return FieldType.password;
    case 'date':
      return FieldType.date;
    case 'number':
      return FieldType.number;
  }
  return null;
}

class CustomField implements JsonConvertable, CSVConvertable {
  String title;
  FieldType fieldType;
  String value;
  bool obscured;

  CustomField({
    this.title = 'Custom Field',
    this.fieldType = FieldType.password,
    this.value = '',
    this.obscured = false,
  });

  CustomField.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? 'Custom Field',
        fieldType = fieldTypeFromName(json['fieldType']) ?? FieldType.text,
        value = json['value'] ?? '',
        obscured = json['private'] ?? false;

  CustomField.fromCSV(List<dynamic> csv)
      : title = csv[0] ?? 'Custom Field',
        fieldType = fieldTypeFromName(csv[1]) ?? FieldType.text,
        value = csv[2] ?? '',
        obscured = csv[3] ?? false;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'fieldType': fieldType.name,
        'value': value,
        'obscured': obscured,
      };

  @override
  List<dynamic> toCSV() => [
        title,
        fieldType.name,
        value,
        obscured,
      ];
}
