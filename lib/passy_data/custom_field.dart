import 'package:passy/passy_data/json_convertable.dart';

enum FieldType { text, password, date, number, error }

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
      return FieldType.error;
  }
}

class CustomField implements JsonConvertable {
  FieldType fieldType;
  String title;
  String value;
  bool private;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'fieldType': fieldType.name,
        'title': title,
        'value': value,
        'private': private,
      };

  factory CustomField.fromJson(Map<String, dynamic> json) => CustomField(
        fieldType: fieldTypeFromName(json['fieldType'] ?? 'text'),
        title: json['title'] ?? 'Custom Field',
        value: json['value'] ?? '',
        private: json['private'] ?? false,
      );

  CustomField(
      {this.fieldType = FieldType.password,
      this.title = 'Custom Field',
      this.value = '',
      this.private = false});
}
