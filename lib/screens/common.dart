import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';

import 'package:passy/common/always_disabled_focus_node.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/widgets/custom_field_editor.dart';
import 'package:passy/widgets/identity_widget.dart';
import 'package:passy/widgets/record_widget.dart';
import 'package:passy/widgets/widgets.dart';
import 'package:passy/common/theme.dart';

import 'assets.dart';
import 'note_screen.dart';
import 'password_screen.dart';

Widget getDoubleActionButton({
  Key? key,
  required Widget body,
  required Widget icon,
  void Function()? onButtonPressed,
  void Function()? onActionPressed,
}) =>
    ElevatedButton(
      key: key,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0),
      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
      onPressed: onButtonPressed,
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: body,
          ),
          IconButton(
            onPressed: onActionPressed,
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            icon: icon,
            splashRadius: 27,
          ),
        ],
      ),
    );

Widget getTextFormFieldButtoned({
  Key? key,
  TextEditingController? controller,
  String? initialValue,
  String? labelText,
  bool obscureText = false,
  Widget? buttonIcon,
  void Function()? onTap,
  void Function(String)? onChanged,
  void Function()? onPressed,
  FocusNode? focusNode,
  List<TextInputFormatter>? inputFormatters,
}) =>
    Row(
      key: key,
      children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
                left: entryPadding.right,
                top: entryPadding.top,
                bottom: entryPadding.bottom),
            child: TextFormField(
              controller: controller,
              initialValue: initialValue,
              obscureText: obscureText,
              decoration: InputDecoration(labelText: labelText),
              onTap: onTap,
              onChanged: onChanged,
              focusNode: focusNode,
              inputFormatters: inputFormatters,
            ),
          ),
        ),
        SizedBox(
          child: Padding(
            padding: EdgeInsets.only(right: entryPadding.right),
            child: FloatingActionButton(
              heroTag: null,
              onPressed: onPressed,
              child: buttonIcon,
            ),
          ),
        )
      ],
    );

Widget getThreeWidgetButton({
  Key? key,
  Widget? left,
  required Widget center,
  Widget? right,
  void Function()? onPressed,
}) =>
    ElevatedButton(
        key: key,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
        child: Padding(
          child: Row(
            children: [
              if (left != null)
                Padding(
                  child: left,
                  padding: const EdgeInsets.only(right: 30),
                ),
              Flexible(
                child: center,
                fit: FlexFit.tight,
              ),
              if (right != null) right,
            ],
          ),
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        ));

AppBar getEntriesScreenAppBar(
  BuildContext context, {
  Key? key,
  required Widget title,
  required void Function()? onSearchPressed,
  required void Function()? onAddPressed,
}) =>
    AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: title,
      actions: [
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          onPressed: onSearchPressed,
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          onPressed: onAddPressed,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );

AppBar getEntryScreenAppBar(
  BuildContext context, {
  Key? key,
  required Widget title,
  required void Function()? onRemovePressed,
  required void Function()? onEditPressed,
}) =>
    AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: title,
      actions: [
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: onRemovePressed,
        ),
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          icon: const Icon(Icons.edit_rounded),
          onPressed: onEditPressed,
        ),
      ],
    );

AppBar getEditScreenAppBar(
  BuildContext context, {
  Key? key,
  required String title,
  void Function()? onSave,
  bool isNew = false,
}) =>
    AppBar(
      key: key,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: isNew
          ? Center(child: Text('Add $title'))
          : Center(child: Text('Edit $title')),
      actions: [
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          onPressed: onSave,
          icon: isNew
              ? const Icon(Icons.add_rounded)
              : const Icon(Icons.check_rounded),
        ),
      ],
    );

Widget buildMonthPicker(
  BuildContext context, {
  TextEditingController? controller,
  String? initialValue,
  Widget? title,
  DateTime Function()? getSelectedDate,
  Function(DateTime)? onChanged,
}) {
  return TextFormField(
      controller: controller,
      initialValue: initialValue,
      decoration: const InputDecoration(labelText: 'Expiration date'),
      focusNode: AlwaysDisabledFocusNode(),
      onTap: () => showDialog(
            context: context,
            builder: (ctx) {
              DateTime _selectedDate = getSelectedDate == null
                  ? DateTime.now().toUtc()
                  : getSelectedDate();
              return AlertDialog(
                title: title,
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: lightContentSecondaryColor),
                      )),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, _selectedDate),
                      child: Text(
                        'Confirm',
                        style: TextStyle(color: lightContentSecondaryColor),
                      )),
                ],
                content: StatefulBuilder(
                  builder: (ctx, setState) {
                    return MonthPicker.single(
                      selectedDate: _selectedDate,
                      firstDate: DateTime.utc(-4294967296),
                      lastDate: DateTime.utc(4294967296),
                      onChanged: (date) {
                        setState(() => _selectedDate = date);
                      },
                      datePickerStyles: DatePickerStyles(
                          currentDateStyle:
                              TextStyle(color: lightContentSecondaryColor),
                          selectedDateStyle:
                              TextStyle(color: lightContentSecondaryColor)),
                    );
                  },
                ),
              );
            },
          ).then((value) {
            if (onChanged != null) onChanged(value);
          }));
}

void sortCustomFields(List<CustomField> customFields) {
  customFields.sort(
    (a, b) => a.title.compareTo(b.title),
  );
}

void sortPasswords(List<Password> passwords) {
  passwords.sort((a, b) {
    int _nickComp = a.nickname.compareTo(b.nickname);
    if (_nickComp == 0) {
      return a.username.compareTo(b.username);
    }
    return _nickComp;
  });
}

void sortPaymentCards(List<PaymentCard> paymentCards) {
  paymentCards.sort((a, b) {
    int _nickComp = a.nickname.compareTo(b.nickname);
    if (_nickComp == 0) {
      return a.cardholderName.compareTo(b.cardholderName);
    }
    return _nickComp;
  });
}

void sortNotes(List<Note> notes) =>
    notes.sort((a, b) => a.title.compareTo(b.title));

void sortIDCards(List<IDCard> idCards) {
  idCards.sort((a, b) {
    int _nickComp = a.nickname.compareTo(b.nickname);
    if (_nickComp == 0) {
      return a.name.compareTo(b.name);
    }
    return _nickComp;
  });
}

void sortIdentities(List<Identity> identities) {
  identities.sort((a, b) {
    int _nickComp = a.nickname.compareTo(b.nickname);
    if (_nickComp == 0) {
      return a.firstAddressLine.compareTo(b.firstAddressLine);
    }
    return _nickComp;
  });
}

Widget getFavIcon(String website, {double width = 50}) {
  SvgPicture _placeholder = SvgPicture.asset(
    logoCircleSvg,
    color: Colors.white,
    width: 50,
    alignment: Alignment.topCenter,
  );
  if (!website.contains(RegExp(r'https://|http://'))) {
    website = 'http://$website';
  }
  String _request =
      'https://s2.googleusercontent.com/s2/favicons?sz=32&domain=$website';

  return CachedNetworkImage(
    imageUrl: _request,
    placeholder: (context, url) => _placeholder,
    errorWidget: (ctx, obj, s) => _placeholder,
    width: width,
    fit: BoxFit.fill,
  );
}

Widget buildPasswordWidget(
    {required BuildContext context, required Password password}) {
  return getThreeWidgetButton(
    left: password.website == ''
        ? logoCircle50White
        : getFavIcon(password.website),
    right: const Icon(Icons.arrow_forward_ios_rounded),
    onPressed: () => Navigator.pushNamed(context, PasswordScreen.routeName,
        arguments: password),
    center: Column(
      children: [
        Align(
          child: Text(
            password.nickname,
          ),
          alignment: Alignment.centerLeft,
        ),
        Align(
          child: Text(
            password.username,
            style: const TextStyle(color: Colors.grey),
          ),
          alignment: Alignment.centerLeft,
        ),
      ],
    ),
  );
}

List<Widget> buildPasswordWidgets({
  required BuildContext context,
  required LoadedAccount account,
  List<Password>? passwords,
}) {
  final List<Widget> _passwordWidgets = [];
  if (passwords == null) {
    passwords = account.passwords.toList();
    sortPasswords(passwords);
  }
  for (Password password in passwords) {
    _passwordWidgets.add(
      PassyPadding(buildPasswordWidget(
        context: context,
        password: password,
      )),
    );
  }
  return _passwordWidgets;
}

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
  sortPaymentCards(_paymentCards);
  final List<Widget> _paymentCardWidgets = [];
  for (PaymentCard paymentCard in paymentCards) {
    _paymentCardWidgets.add(buildPaymentCardWidget(
        paymentCard: paymentCard,
        onPressed: onPressed == null ? null : () => onPressed(paymentCard)));
  }
  return _paymentCardWidgets;
}

Widget buildNoteWidget({required BuildContext context, required Note note}) {
  return getThreeWidgetButton(
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
  sortNotes(notes);
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
  sortIdentities(identities);
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
}) {
  if (shouldSort) sortCustomFields(customFields);
  return StatefulBuilder(
      builder: (ctx, setState) => ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              CustomField _customField = customFields[index];
              return CustomFieldEditor(
                customField: _customField,
                onChanged: (value) =>
                    setState(() => _customField.value = value),
                onRemovePressed: () =>
                    setState(() => customFields.removeAt(index)),
              );
            },
            itemCount: customFields.length,
          ));
}
