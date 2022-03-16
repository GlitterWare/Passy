import 'package:json_annotation/json_annotation.dart';

part 'custom_field.g.dart';

enum FieldType { text, password, date, number }

@JsonSerializable()
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

  factory CustomField.fromJson(Map<String, dynamic> json) =>
      _$CustomFieldFromJson(json);
  Map<String, dynamic> toJson() => _$CustomFieldToJson(this);
}
