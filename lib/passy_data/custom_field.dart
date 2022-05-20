import 'package:passy/passy_data/common.dart';

import 'csv_convertable.dart';
import 'json_convertable.dart';

enum FieldType { text, password, date, number }

FieldType? fieldTypeFromName(String name) {
  switch (name) {
    case 'text':
      return FieldType.text;
    case 'number':
      return FieldType.number;
    case 'password':
      return FieldType.password;
    case 'date':
      return FieldType.date;
  }
  return null;
}

class CustomField with JsonConvertable, CSVConvertable {
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

  CustomField.fromCSV(List csv)
      : title = csv[0][0] ?? 'Custom Field',
        fieldType = fieldTypeFromName(csv[0][1]) ?? FieldType.text,
        value = csv[0][2] ?? '',
        obscured = boolFromString(csv[0][3]) ?? false;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'fieldType': fieldType.name,
        'value': value,
        'obscured': obscured,
      };

  @override
  List<List> toCSV() => [
        [
          title,
          fieldType.name,
          value,
          obscured.toString(),
        ]
      ];
}
