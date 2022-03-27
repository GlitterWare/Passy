import 'package:json_annotation/json_annotation.dart';

const _$FieldTypeEnumMap = {
  FieldType.text: 'text',
  FieldType.password: 'password',
  FieldType.date: 'date',
  FieldType.number: 'number',
};

enum FieldType { text, password, date, number }

class CustomField {
  FieldType fieldType;
  String title;
  String value;
  bool private;

  CustomField(
      {this.fieldType = FieldType.password,
      this.title = 'Custom Field',
      this.value = '',
      this.private = false});

  factory CustomField.fromJson(Map<String, dynamic> json) => CustomField(
        fieldType: $enumDecodeNullable(_$FieldTypeEnumMap, json['fieldType']) ??
            FieldType.password,
        title: json['title'] as String? ?? 'Custom Field',
        value: json['value'] as String? ?? '',
        private: json['private'] as bool? ?? false,
      );
  Map<String, dynamic> toJson() => <String, dynamic>{
        'fieldType': _$FieldTypeEnumMap[fieldType],
        'title': title,
        'value': value,
        'private': private,
      };
}
