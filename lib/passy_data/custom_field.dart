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
  bool multiline;

  CustomField({
    this.title = 'Custom Field',
    this.fieldType = FieldType.text,
    this.value = '',
    this.obscured = false,
    this.multiline = false,
  });

  CustomField.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? 'Custom Field',
        fieldType = fieldTypeFromName(json['fieldType']) ?? FieldType.text,
        value = json['value'] ?? '',
        obscured = json['obscured'] ?? false,
        multiline = json['multiline'] ?? false;

  CustomField.fromCSV(List csv)
      : title = csv.isNotEmpty ? csv[0] : 'Custom Field',
        fieldType =
            fieldTypeFromName(csv.length >= 2 ? csv[1] : '') ?? FieldType.text,
        value = csv.length >= 3 ? csv[2] : '',
        obscured = boolFromString(csv.length >= 4 ? csv[3] : '') ?? false,
        multiline = boolFromString(csv.length >= 5 ? csv[4] : '') ?? false;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'fieldType': fieldType.name,
        'value': value,
        'obscured': obscured,
        'multiline': multiline,
      };

  @override
  List toCSV() => [
        title,
        fieldType.name,
        value,
        obscured.toString(),
        multiline.toString(),
      ];
}
