import 'package:flutter/material.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/widgets/widgets.dart';

import 'common.dart';

class EditCustomFieldScreen extends StatefulWidget {
  const EditCustomFieldScreen({Key? key}) : super(key: key);

  static const routeName = '/editCustomField';

  @override
  State<StatefulWidget> createState() => _EditCustomFieldScreen();
}

class _EditCustomFieldScreen extends State<EditCustomFieldScreen> {
  final CustomField _customField = CustomField();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getEditScreenAppBar(
        context,
        title: 'custom field',
        onSave: () => Navigator.pop(context, _customField),
        isNew: true,
      ),
      body: ListView(children: [
        PassyTextFormField(
          initialValue: _customField.title,
          decoration: const InputDecoration(labelText: 'Title'),
          onChanged: (value) => setState(() => _customField.title = value),
        ),
        PassyPadding(DropdownButtonFormField(
          items: [
            DropdownMenuItem(
              child: Text(FieldType.text.name[0].toUpperCase() +
                  FieldType.text.name.substring(1)),
              value: FieldType.text,
            ),
            DropdownMenuItem(
              child: Text(FieldType.number.name[0].toUpperCase() +
                  FieldType.number.name.substring(1)),
              value: FieldType.number,
            ),
            DropdownMenuItem(
              child: Text(FieldType.password.name[0].toUpperCase() +
                  FieldType.password.name.substring(1)),
              value: FieldType.password,
            ),
            DropdownMenuItem(
              child: Text(FieldType.date.name[0].toUpperCase() +
                  FieldType.date.name.substring(1)),
              value: FieldType.date,
            ),
          ],
          value: _customField.fieldType,
          decoration: const InputDecoration(labelText: 'Type'),
          onChanged: (value) => _customField.fieldType = value as FieldType,
        )),
        PassyPadding(DropdownButtonFormField(
          items: const [
            DropdownMenuItem(
              child: Text('True'),
              value: true,
            ),
            DropdownMenuItem(
              child: Text('False'),
              value: false,
            ),
          ],
          value: _customField.obscured,
          decoration: const InputDecoration(labelText: 'Obscured'),
          onChanged: (value) => _customField.obscured = value as bool,
        )),
      ]),
    );
  }
}
