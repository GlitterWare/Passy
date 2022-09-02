import 'package:flutter/material.dart';

import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/payment_card.dart';
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

List<Widget> buildPaymentCardWidgets(
  BuildContext context, {
  required Iterable<PaymentCard> paymentCards,
  void Function(PaymentCard paymentCard)? onPressed,
}) {
  final List<PaymentCard> _paymentCards = paymentCards.toList();
  PassySort.sortPaymentCards(_paymentCards);
  final List<Widget> _paymentCardWidgets = [];
  for (PaymentCard paymentCard in paymentCards) {
    _paymentCardWidgets.add(PaymentCardButton(
      paymentCard: paymentCard,
      onPressed: onPressed == null ? null : () => onPressed(paymentCard),
    ));
  }
  return _paymentCardWidgets;
}

Widget buildNoteWidget({required BuildContext context, required Note note}) {
  return ThreeWidgetButton(
    left: const Icon(Icons.note_rounded),
    right: const Icon(Icons.arrow_forward_ios_rounded),
    onPressed: () {
      Navigator.pushNamed(context, NoteScreen.routeName, arguments: note);
    },
    center: Column(
      children: [
        Align(
          child: Text(
            note.title,
          ),
          alignment: Alignment.centerLeft,
        ),
      ],
    ),
  );
}

List<Widget> buildNoteWidgets({
  required BuildContext context,
  required List<Note> notes,
}) {
  final List<Widget> _noteWidgets = [];
  PassySort.sortNotes(notes);
  for (Note note in notes) {
    _noteWidgets.add(
      PassyPadding(buildNoteWidget(
        context: context,
        note: note,
      )),
    );
  }
  return _noteWidgets;
}

List<Widget> buildIdentityWidgets({
  required BuildContext context,
  required List<Identity> identities,
}) {
  final List<Widget> _identityWidgets = [];
  PassySort.sortIdentities(identities);
  for (Identity identity in identities) {
    _identityWidgets.add(PassyPadding(IdentityWidget(identity: identity)));
  }
  return _identityWidgets;
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
