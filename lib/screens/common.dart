import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:credit_card_type_detector/credit_card_type_detector.dart';

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

CardType cardTypeFromCreditCardType(CreditCardType cardType) {
  switch (cardType) {
    case CreditCardType.visa:
      return CardType.visa;
    case CreditCardType.mastercard:
      return CardType.mastercard;
    case CreditCardType.amex:
      return CardType.americanExpress;
    case CreditCardType.discover:
      return CardType.discover;
    default:
      return CardType.otherBrand;
  }
}

CardType cardTypeFromNumber(String number) =>
    cardTypeFromCreditCardType(detectCCType(number));

Widget buildPaymentCardWidget({
  required PaymentCard paymentCard,
  bool obscureCardNumber = true,
  bool obscureCardCvv = true,
  bool isSwipeGestureEnabled = false,
  void Function()? onPressed,
}) {
  String beautifyCardNumber(String cardNumber) {
    if (cardNumber.isEmpty) {
      return '';
    }
    String _value = cardNumber.trim();
    cardNumber = _value[0];
    for (int i = 1; i < _value.length; i++) {
      if (i % 4 == 0) cardNumber += ' ';
      cardNumber += _value[i];
    }
    return cardNumber;
  }

  return Center(
    child: Stack(
      children: [
        TextButton(
          onPressed: onPressed,
          child: CreditCardWidget(
            glassmorphismConfig: Glassmorphism.defaultConfig(),
            width: 350,
            height: 200,
            cardNumber: beautifyCardNumber(paymentCard.cardNumber),
            expiryDate: paymentCard.exp,
            cardHolderName: paymentCard.cardholderName,
            customCardTypeIcons: [
              CustomCardTypeIcon(
                  cardType: CardType.otherBrand,
                  cardImage: SvgPicture.asset(
                    'assets/images/logo_circle.svg',
                    color: Colors.purple,
                    width: 50,
                  ))
            ],
            cvvCode: paymentCard.cvv,
            showBackView: false,
            obscureCardNumber: obscureCardNumber,
            obscureCardCvv: obscureCardCvv,
            isHolderNameVisible: true,
            cardBgColor: Colors.red,
            backgroundImage: 'assets/images/payment_card_bg.png',
            cardType: cardTypeFromNumber(paymentCard.cardNumber),
            isSwipeGestureEnabled: isSwipeGestureEnabled,
            onCreditCardWidgetChange: (brand) {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(35, 32, 0, 0),
          child: Text(
            paymentCard.nickname,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

List<Widget> buildPaymentCardWidgets(
  BuildContext context, {
  required Iterable<PaymentCard> paymentCards,
  void Function(PaymentCard paymentCard)? onPressed,
}) {
  final List<PaymentCard> _paymentCards = paymentCards.toList();
  PassySort.sortPaymentCards(_paymentCards);
  final List<Widget> _paymentCardWidgets = [];
  for (PaymentCard paymentCard in paymentCards) {
    _paymentCardWidgets.add(buildPaymentCardWidget(
        paymentCard: paymentCard,
        onPressed: onPressed == null ? null : () => onPressed(paymentCard)));
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
    PassyPadding(PassyRecord(
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
