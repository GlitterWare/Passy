import 'package:flutter/material.dart';

import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/screen.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'main_screen.dart';
import 'note_screen.dart';
import 'passwords_screen.dart';

const screenToRouteName = {
  Screen.main: MainScreen.routeName,
  Screen.passwords: PasswordsScreen.routeName,
  Screen.notes: '',
  Screen.idCards: '',
  Screen.identities: '',
};

List<Widget> buildNoteWidgets({
  required BuildContext context,
  required List<Note> notes,
}) {
  final List<Widget> _noteWidgets = [];
  PassySort.sortNotes(notes);
  for (Note note in notes) {
    _noteWidgets.add(
      PassyPadding(NoteButton(
        note: note,
        onPressed: () {
          Navigator.pushNamed(context, NoteScreen.routeName, arguments: note);
        },
      )),
    );
  }
  return _noteWidgets;
}

Widget buildCustomField(BuildContext context, CustomField customField) =>
    PassyPadding(RecordButton(
      title: customField.title,
      value: customField.value,
      obscureValue: customField.obscured,
      isPassword: customField.fieldType == FieldType.password,
    ));

Widget buildCustomFieldEditors({
  required List<CustomField> customFields,
  bool shouldSort = true,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
}) {
  if (shouldSort) PassySort.sortCustomFields(customFields);
  return StatefulBuilder(
      builder: (ctx, setState) => ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              CustomField _customField = customFields[index];
              return Padding(
                padding: padding,
                child: CustomFieldEditor(
                  customField: _customField,
                  onChanged: (value) =>
                      setState(() => _customField.value = value),
                  onRemovePressed: () =>
                      setState(() => customFields.removeAt(index)),
                ),
              );
            },
            itemCount: customFields.length,
          ));
}
