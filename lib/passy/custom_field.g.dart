// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomField _$CustomFieldFromJson(Map<String, dynamic> json) => CustomField(
      fieldType: $enumDecodeNullable(_$FieldTypeEnumMap, json['fieldType']) ??
          FieldType.password,
      title: json['title'] as String? ?? 'Custom Field',
      value: json['value'] as String? ?? '',
      private: json['private'] as bool? ?? false,
    );

Map<String, dynamic> _$CustomFieldToJson(CustomField instance) =>
    <String, dynamic>{
      'fieldType': _$FieldTypeEnumMap[instance.fieldType],
      'title': instance.title,
      'value': instance.value,
      'private': instance.private,
    };

const _$FieldTypeEnumMap = {
  FieldType.text: 'text',
  FieldType.password: 'password',
  FieldType.date: 'date',
  FieldType.number: 'number',
};
