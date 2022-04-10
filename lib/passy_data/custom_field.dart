import 'package:passy/passy_data/json_convertable.dart';

enum FieldType { text, password, date, number }

const fieldTypeToJson = {
  FieldType.text: 'text',
  FieldType.password: 'password',
  FieldType.date: 'date',
  FieldType.number: 'number',
};

const fieldTypeFromJson = {
  'text': FieldType.text,
  'password': FieldType.password,
  'date': FieldType.date,
  'number': FieldType.number,
};

class CustomField implements JsonConvertable {
  FieldType fieldType;
  String title;
  String value;
  bool private;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'fieldType': fieldTypeToJson[fieldType],
        'title': title,
        'value': value,
        'private': private,
      };

  factory CustomField.fromJson(Map<String, dynamic> json) => CustomField(
        fieldType: fieldTypeFromJson[json['fieldType']] ?? FieldType.password,
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
