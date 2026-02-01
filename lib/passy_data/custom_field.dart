import 'package:passy/passy_data/common.dart';

import 'csv_convertable.dart';
import 'json_convertable.dart';
import 'tfa.dart';

enum FieldType { text, password, date, number, tfa }

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
    case 'tfa':
      return FieldType.tfa;
  }
  return null;
}

class CustomField with JsonConvertable, CSVConvertable {
  String title;
  FieldType fieldType;
  String value;
  bool obscured;
  bool multiline;
  TFA? tfa;

  CustomField({
    this.title = 'Custom Field',
    this.fieldType = FieldType.text,
    this.value = '',
    this.obscured = false,
    this.multiline = false,
    this.tfa,
  });

  CustomField.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? 'Custom Field',
        fieldType = fieldTypeFromName(json['fieldType']) ?? FieldType.text,
        value = json['value'] ?? '',
        obscured = json['obscured'] ?? false,
        multiline = json['multiline'] ?? false,
        tfa = json['tfa'] == null ? null : TFA.fromJson(json['tfa']);

  CustomField._fromCSV(List csv)
      : title = csv[0],
        fieldType = fieldTypeFromName(csv[1]) ?? FieldType.text,
        value = csv[2],
        obscured = boolFromString(csv[3]) ?? false,
        multiline = boolFromString(csv[4]) ?? false,
        tfa = csv[5].isEmpty ? null : TFA.fromCSV(csv[5] as List);

  factory CustomField.fromCSV(List csv) {
    while (csv.length < 6) {
      csv.add('');
    }
    return CustomField._fromCSV(csv);
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'fieldType': fieldType.name,
        'value': value,
        'obscured': obscured,
        'multiline': multiline,
        'tfa': tfa?.toJson(),
      };

  @override
  List toCSV() => [
        title,
        fieldType.name,
        value,
        obscured.toString(),
        multiline.toString(),
        tfa?.toCSV() ?? '',
      ];
}
