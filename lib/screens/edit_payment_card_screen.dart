import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'edit_custom_field_screen.dart';
import 'main_screen.dart';
import 'payment_card_screen.dart';
import 'splash_screen.dart';
import 'payment_cards_screen.dart';

class EditPaymentCardScreen extends StatefulWidget {
  const EditPaymentCardScreen({Key? key}) : super(key: key);

  static const routeName = '${PaymentCardScreen.routeName}/editPaymentCard';

  @override
  State<StatefulWidget> createState() => _EditPaymentCardScreen();
}

class _EditPaymentCardScreen extends State<EditPaymentCardScreen> {
  bool _isLoaded = false;
  bool _isNew = false;

  String? _key;
  List<CustomField> _customFields = [];
  String _additionalInfo = '';
  List<String> _tags = [];
  String _nickname = '';
  String _cardNumber = '';
  String _cardholderName = '';
  String _cvv = '';
  String _exp = '';
  List<String> _attachments = [];

  @override
  void initState() {
    super.initState();
    {
      DateTime _date = DateTime.now().toUtc();
      String _month = _date.month.toString();
      String _year = _date.year.toString();
      if (_month.length == 1) {
        _month = '0' + _month;
      }
      _exp = _month + '/' + _year;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      Object? _args = ModalRoute.of(context)!.settings.arguments;
      _isNew = _args == null;
      if (!_isNew) {
        PaymentCard _paymentCardArgs = _args as PaymentCard;
        _key = _paymentCardArgs.key;
        _customFields = _paymentCardArgs.customFields
            .map((e) => CustomField(
                title: e.title,
                fieldType: e.fieldType,
                value: e.value,
                obscured: e.obscured,
                multiline: e.multiline))
            .toList();
        _additionalInfo = _paymentCardArgs.additionalInfo;
        _tags = _paymentCardArgs.tags;
        _nickname = _paymentCardArgs.nickname;
        _cardNumber = _paymentCardArgs.cardNumber;
        _cardholderName = _paymentCardArgs.cardholderName;
        _cvv = _paymentCardArgs.cvv;
        _exp = _paymentCardArgs.exp;
        _attachments = List.from(_paymentCardArgs.attachments);
      }
      _isLoaded = true;
    }

    return Scaffold(
      appBar: EditScreenAppBar(
        title: localizations.paymentCard.toLowerCase(),
        onSave: () async {
          final LoadedAccount _account = data.loadedAccount!;
          _customFields.removeWhere((element) => element.value == '');
          PaymentCard _paymentCardArgs = PaymentCard(
            key: _key,
            customFields: _customFields,
            additionalInfo: _additionalInfo,
            tags: _tags,
            nickname: _nickname,
            cardNumber: _cardNumber,
            cardholderName: _cardholderName,
            cvv: _cvv,
            exp: _exp,
            attachments: _attachments,
          );
          Navigator.pushNamed(context, SplashScreen.routeName);
          await _account.setPaymentCard(_paymentCardArgs);
          Navigator.popUntil(
              context, (r) => r.settings.name == MainScreen.routeName);
          Navigator.pushNamed(context, PaymentCardsScreen.routeName);
          Navigator.pushNamed(context, PaymentCardScreen.routeName,
              arguments: _paymentCardArgs);
        },
        isNew: _isNew,
      ),
      body: ListView(
        children: [
          PaymentCardButton(
            paymentCard: PaymentCardMeta(
              key: '',
              tags: [],
              nickname: _nickname,
              cardNumber: _cardNumber,
              cardholderName: _cardholderName,
              exp: _exp,
            ),
            obscureCardNumber: false,
            obscureCardCvv: false,
            isSwipeGestureEnabled: false,
          ),
          AttachmentsEditor(
            files: _attachments,
            onFileAdded: (key) => setState(() => _attachments.add(key)),
            onFileRemoved: (key) => setState(() => _attachments.remove(key)),
          ),
          PassyPadding(TextFormField(
            initialValue: _nickname,
            decoration: InputDecoration(labelText: localizations.nickname),
            onChanged: (value) => setState(() => _nickname = value.trim()),
          )),
          PassyPadding(TextFormField(
            initialValue: _cardNumber,
            decoration: InputDecoration(labelText: localizations.cardNumber),
            onChanged: (value) => setState(() => _cardNumber = value),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          )),
          PassyPadding(TextFormField(
            initialValue: _cardholderName,
            decoration:
                InputDecoration(labelText: localizations.cardHolderName),
            onChanged: (value) =>
                setState(() => _cardholderName = value.trim()),
          )),
          PassyPadding(MonthPickerFormField(
            key: UniqueKey(),
            initialValue: _exp,
            title: localizations.expirationDate,
            getSelectedDate: () {
              DateTime _now = DateTime.now();
              List<String> _date = _exp.split('/');
              if (_date.length < 2) return DateTime.now();
              String _month = _date[0];
              String _year = _date[1];
              if (_month[0] == '0') {
                _month = _month[1];
              }
              int? _monthDecoded = int.tryParse(_month);
              if (_monthDecoded == null) return _now;
              int? _yearDecoded = int.tryParse(_year);
              if (_yearDecoded == null) return _now;
              if (_yearDecoded < _now.year) _yearDecoded = _now.year;
              return DateTime.utc(_yearDecoded, _monthDecoded);
            },
            onChanged: (selectedDate) {
              String _month = selectedDate.month.toString();
              String _year = selectedDate.year.toString();
              if (_month.length == 1) _month = '0' + _month;
              setState(() => _exp = _month + '/' + _year);
            },
          )),
          PassyPadding(TextFormField(
            initialValue: _cvv,
            decoration: const InputDecoration(labelText: 'CVV'),
            onChanged: (value) => setState(() => _cvv = value),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          )),
          CustomFieldsEditor(
            customFields: _customFields,
            shouldSort: true,
            padding: PassyTheme.passyPadding,
            constructCustomField: () async => (await Navigator.pushNamed(
              context,
              EditCustomFieldScreen.routeName,
            )) as CustomField?,
          ),
          PassyPadding(TextFormField(
            initialValue: _additionalInfo,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              labelText: localizations.additionalInfo,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide:
                    const BorderSide(color: PassyTheme.lightContentColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(
                    color: PassyTheme.darkContentSecondaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide:
                    const BorderSide(color: PassyTheme.lightContentColor),
              ),
            ),
            onChanged: (value) => setState(() => _additionalInfo = value),
          )),
        ],
      ),
    );
  }
}
