import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';

import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.done),
        onPressed: () => Navigator.pop(context, _customField),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
        PassyPadding(EnumDropDownButtonFormField(
          values: const [
            FieldType.text,
            FieldType.number,
            FieldType.password,
            FieldType.date,
          ],
          itemBuilder: (FieldType type) {
            switch (type) {
              case FieldType.text:
                return Text(localizations.text);
              case FieldType.password:
                return Text(localizations.password);
              case FieldType.date:
                return Text(localizations.date);
              case FieldType.number:
                return Text(localizations.number);
            }
          },
          value: _customField.fieldType,
          decoration: InputDecoration(labelText: localizations.type),
          onChanged: (value) {
            if (value == null) return;
            dynamic type = value;
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
