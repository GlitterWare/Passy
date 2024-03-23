import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';

import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

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
      appBar: EditScreenAppBar(
        title: localizations.customField.toLowerCase(),
        onSave: () => Navigator.pop(context, _customField),
        isNew: true,
      ),
      body: ListView(children: [
        PassyPadding(TextFormField(
          initialValue: _customField.title,
          decoration: InputDecoration(labelText: localizations.title),
          onChanged: (value) => setState(() => _customField.title = value),
        )),
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
          decoration: InputDecoration(labelText: localizations.type),
          onChanged: (value) {
            if (value == null) return;
            dynamic type = value as FieldType;
            bool obscured;
            if (type == FieldType.password) {
              obscured = true;
            } else {
              obscured = false;
            }
            setState(() {
              _customField.fieldType = type;
              _customField.obscured = obscured;
            });
          },
        )),
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.obscured),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.hide_source),
          ),
          right: Switch(
            activeColor: Colors.greenAccent,
            value: _customField.obscured,
            onChanged: (value) => setState(() => _customField.obscured = value),
          ),
          onPressed: () =>
              setState(() => _customField.obscured = !_customField.obscured),
        )),
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.multiline),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.list_outlined),
          ),
          right: Switch(
            activeColor: Colors.greenAccent,
            value: _customField.multiline,
            onChanged: (value) =>
                setState(() => _customField.multiline = value),
          ),
          onPressed: () =>
              setState(() => _customField.multiline = !_customField.multiline),
        )),
      ]),
    );
  }
}
