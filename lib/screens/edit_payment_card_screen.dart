import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/widgets/widgets.dart';

import '../common/theme.dart';
import 'common.dart';
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
        _customFields = List<CustomField>.from(_paymentCardArgs.customFields
            .map((e) => CustomField(
                title: e.title,
                fieldType: e.fieldType,
                value: e.value,
                obscured: e.obscured)));
        _additionalInfo = _paymentCardArgs.additionalInfo;
        _tags = _paymentCardArgs.tags;
        _nickname = _paymentCardArgs.nickname;
        _cardNumber = _paymentCardArgs.cardNumber;
        _cardholderName = _paymentCardArgs.cardholderName;
        _cvv = _paymentCardArgs.cvv;
        _exp = _paymentCardArgs.exp;
      }
      _isLoaded = true;
    }

    return Scaffold(
      appBar: EditScreenAppBar(
        title: 'payment card',
        onSave: () {
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
          );
          _account.setPaymentCard(_paymentCardArgs);
          Navigator.pushNamed(context, SplashScreen.routeName);
          _account.save().whenComplete(() {
            Navigator.popUntil(
                context, (r) => r.settings.name == MainScreen.routeName);
            Navigator.pushNamed(context, PaymentCardsScreen.routeName);
            Navigator.pushNamed(context, PaymentCardScreen.routeName,
                arguments: _paymentCardArgs);
          });
        },
        isNew: _isNew,
      ),
      body: ListView(
        children: [
          buildPaymentCardWidget(
            paymentCard: PaymentCard(
              nickname: _nickname,
              cardNumber: _cardNumber,
              cardholderName: _cardholderName,
              exp: _exp,
              cvv: _cvv,
            ),
            obscureCardNumber: false,
            obscureCardCvv: false,
            isSwipeGestureEnabled: false,
          ),
          PassyPadding(TextFormField(
            initialValue: _nickname,
            decoration: const InputDecoration(labelText: 'Nickname'),
            onChanged: (value) => setState(() => _nickname = value.trim()),
          )),
          PassyPadding(TextFormField(
            initialValue: _cardNumber,
            decoration: const InputDecoration(labelText: 'Card number'),
            onChanged: (value) => setState(() => _cardNumber = value),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          )),
          PassyPadding(TextFormField(
            initialValue: _cardholderName,
            decoration: const InputDecoration(labelText: 'Card holder name'),
            onChanged: (value) =>
                setState(() => _cardholderName = value.trim()),
          )),
          PassyPadding(buildMonthPicker(context,
              initialValue: _exp,
              title: const Text('Expiration date'), getSelectedDate: () {
            List<String> _date = _exp.split('/');
            String _month = _date[0];
            String _year = _date[1];
            if (_month[0] == '0') {
              _month = _month[1];
            }
            return DateTime.utc(int.parse(_year), int.parse(_month));
          }, onChanged: (selectedDate) {
            String _month = selectedDate.month.toString();
            String _year = selectedDate.year.toString();
            if (_month.length == 1) _month = '0' + _month;
            setState(() {
              _exp = _month + '/' + _year;
            });
          })),
          PassyPadding(TextFormField(
            initialValue: _cvv,
            decoration: const InputDecoration(labelText: 'CVV'),
            onChanged: (value) => setState(() => _cvv = value),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          )),
          PassyPadding(ThreeWidgetButton(
            left: const Icon(Icons.add_rounded),
            center: const Text('Add custom field'),
            onPressed: () => Navigator.pushNamed(
              context,
              EditCustomFieldScreen.routeName,
            ).then(
              (value) {
                if (value != null) {
                  setState(() => _customFields.add(value as CustomField));
                }
              },
            ),
          )),
          buildCustomFieldEditors(
              customFields: _customFields, padding: passyPadding),
          PassyPadding(TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              labelText: 'Additional info',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28.0),
                borderSide: BorderSide(color: lightContentColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28.0),
                borderSide: BorderSide(color: darkContentSecondaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28.0),
                borderSide: BorderSide(color: lightContentColor),
              ),
            ),
            onChanged: (value) => setState(() => _additionalInfo = value),
          )),
        ],
      ),
    );
  }
}
