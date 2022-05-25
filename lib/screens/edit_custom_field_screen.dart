import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/widgets/passy_back_button.dart';

import 'edit_password_screen.dart';

class EditCustomFieldScreen extends StatefulWidget {
  const EditCustomFieldScreen({Key? key}) : super(key: key);

  static const routeName = '${EditPasswordScreen.routeName}/editCustomField';

  @override
  State<StatefulWidget> createState() => _EditCustomFieldScreen();
}

class _EditCustomFieldScreen extends State<EditCustomFieldScreen> {
  @override
  Widget build(BuildContext context) {
    CustomField _customField = CustomField();
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(
          child: Text('Add custom field'),
        ),
        actions: [
          IconButton(
              padding: appBarButtonPadding,
              splashRadius: appBarButtonSplashRadius,
              onPressed: () {
                Navigator.pop(context, _customField);
              },
              icon: const Icon(Icons.add_rounded)),
        ],
      ),
      body: ListView(children: [
        Padding(
          padding: entryPadding,
          child: TextFormField(
            controller: TextEditingController(text: _customField.title),
            decoration: const InputDecoration(labelText: 'Title'),
            onChanged: (value) => _customField.title = value,
          ),
        ),
        Padding(
          padding: entryPadding,
          child: DropdownButtonFormField(
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
          ),
        ),
        Padding(
          padding: entryPadding,
          child: DropdownButtonFormField(
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
          ),
        ),
      ]),
    );
  }
}
