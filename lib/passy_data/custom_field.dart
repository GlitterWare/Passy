import 'common.dart';
import 'csv_convertable.dart';
import 'json_convertable.dart';

enum FieldType { text, password, date, number }

FieldType fieldTypeFromName(String name) {
  switch (name) {
    case 'text':
      return FieldType.text;
    case 'password':
      return FieldType.password;
    case 'date':
      return FieldType.date;
    case 'number':
      return FieldType.number;
    default:
      throw Exception('Cannot convert String \'$name\' to FieldType');
  }
}

class CustomField implements JsonConvertable, CSVConvertable {
  static const csvSchema = {
    'fieldType': 1,
    'title': 2,
    'value': 3,
    'obscured': 4
  };

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
        fieldType = fieldTypeFromName(json['fieldType'] ?? 'text'),
        value = json['value'] ?? '',
        obscured = json['private'] ?? false;

  CustomField.fromCSV(List<dynamic> csv,
      {Map<String, int> csvSchema = csvSchema})
      : title = csv[csvSchema['title']!],
        fieldType = fieldTypeFromName(csv[csvSchema['title']!]),
        value = csv[csvSchema['value']!],
        obscured = csv[csvSchema['obscured']!];

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'fieldType': fieldType.name,
        'value': value,
        'obscured': obscured,
      };

  @override
  List<List<dynamic>> toCSV() => jsonToCSV('customField', toJson());
}
