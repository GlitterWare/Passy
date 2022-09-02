import 'package:flutter/material.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class CustomFieldButton extends StatelessWidget {
  final CustomField customField;

  const CustomFieldButton({Key? key, required this.customField})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RecordButton(
      title: customField.title,
      value: customField.value,
      obscureValue: customField.obscured,
      isPassword: customField.fieldType == FieldType.password,
    );
  }
}
