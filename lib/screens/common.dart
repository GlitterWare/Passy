import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/always_disabled_focus_node.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/screens/password_screen.dart';
import 'package:passy/widgets/double_action_button.dart';
import 'package:passy/widgets/text_form_field_buttoned.dart';
import 'package:passy/widgets/three_widget_button.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';

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

Widget getFavIcon(String website, {double width = 50}) {
  if (!website.contains(RegExp(r'https://|http://'))) {
    website = 'http://$website';
  }
  String _request =
      'https://s2.googleusercontent.com/s2/favicons?sz=32&domain=$website';

  return CachedNetworkImage(
    imageUrl: _request,
    placeholder: (context, url) => logoCircle50White,
    errorWidget: (ctx, obj, s) => logoCircle50White,
    width: width,
    fit: BoxFit.fill,
  );
}

Widget buildPasswordWidget(
    {required BuildContext context, required Password password}) {
  return ThreeWidgetButton(
    left: password.website == ''
        ? logoCircle50White
        : getFavIcon(password.website),
    right: const Icon(Icons.arrow_forward_ios_rounded),
    onPressed: () {
      Navigator.pushNamed(context, PasswordScreen.routeName,
          arguments: password);
    },
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
    _passwordWidgets
        .add(buildPasswordWidget(context: context, password: password));
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
  void Function(PaymentCard paymentCard)? onPressed,
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
          onPressed: onPressed == null ? null : () => onPressed(paymentCard),
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
    _paymentCardWidgets.add(
        buildPaymentCardWidget(paymentCard: paymentCard, onPressed: onPressed));
  }
  return _paymentCardWidgets;
}

Widget buildRecord(BuildContext context, String title, String value,
        {bool obscureValue = false, bool isPassword = false}) =>
    DoubleActionButton(
      body: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: lightContentSecondaryColor),
          ),
          Text(
            obscureValue ? '\u2022' * 6 : value,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      icon: const Icon(Icons.copy),
      onButtonPressed: () => showDialog(
        context: context,
        builder: (_) =>
            getRecordDialog(value: value, highlightSpecial: isPassword),
      ),
      onActionPressed: () => Clipboard.setData(ClipboardData(text: value)),
    );

Widget buildCustomFields(List<CustomField> customFields) => StatefulBuilder(
    builder: (ctx, setState) => ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            CustomField _customField = customFields[index];
            TextEditingController _controller =
                TextEditingController(text: _customField.value);
            bool _isDate = _customField.fieldType == FieldType.date;
            DateTime? _date;
            if (_isDate) {
              if (_customField.value == '') {
                _date = DateTime.now();
              } else {
                List<String> _dateSplit = _customField.value.split('/');
                _date = DateTime(
                  int.parse(_dateSplit[2]),
                  int.parse(_dateSplit[1]),
                  int.parse(_dateSplit[0]),
                );
              }
            }
            return TextFormFieldButtoned(
              controller: _controller,
              focusNode: _isDate ? AlwaysDisabledFocusNode() : null,
              labelText: _customField.title,
              buttonIcon: const Icon(Icons.remove_rounded),
              onChanged: (value) => _customField.value = value,
              onTap: _isDate
                  ? () => showDatePicker(
                        context: context,
                        initialDate:
                            _customField.value == '' ? DateTime.now() : _date!,
                        firstDate: DateTime.utc(0, 04, 20),
                        lastDate: DateTime.utc(275760, 09, 13),
                        builder: (context, widget) => Theme(
                          data: ThemeData(
                            colorScheme: ColorScheme.dark(
                              primary: lightContentSecondaryColor,
                              onPrimary: lightContentColor,
                            ),
                          ),
                          child: widget!,
                        ),
                      ).then((value) {
                        if (value == null) return;
                        setState(() => _customField.value =
                            value.day.toString() +
                                '/' +
                                value.month.toString() +
                                '/' +
                                value.year.toString());
                      })
                  : null,
              onPressed: () => setState(() => customFields.removeAt(index)),
              inputFormatters: [
                if (_customField.fieldType == FieldType.number)
                  FilteringTextInputFormatter.digitsOnly,
              ],
            );
          },
          itemCount: customFields.length,
        ));
