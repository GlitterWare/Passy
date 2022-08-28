import 'package:flutter/material.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/screens/edit_id_card_screen.dart';

import 'common.dart';

class IDCardScreen extends StatefulWidget {
  const IDCardScreen({Key? key}) : super(key: key);

  static const routeName = '/idCard';

  @override
  State<StatefulWidget> createState() => _IDCardScreen();
}

class _IDCardScreen extends State<IDCardScreen> {
  @override
  Widget build(BuildContext context) {
    final IDCard _idCard = ModalRoute.of(context)!.settings.arguments as IDCard;

    void _onRemovePressed(IDCard _idCard) {}

    void _onEditPressed(IDCard _idCard) {
      Navigator.pushNamed(
        context,
        EditIDCardScreen.routeName,
        arguments: _idCard,
      );
    }

    return Scaffold(
      appBar: getEntryScreenAppBar(
        context,
        title: const Center(child: Text('ID Card')),
        onRemovePressed: () => _onRemovePressed(_idCard),
        onEditPressed: () => _onEditPressed(_idCard),
      ),
      body: ListView(
        children: [
          if (_idCard.nickname != '')
            buildRecord(context, 'Nickname', _idCard.nickname),
          if (_idCard.type != '') buildRecord(context, 'Type', _idCard.type),
          if (_idCard.idNumber != '')
            buildRecord(context, 'ID Number', _idCard.idNumber),
          if (_idCard.name != '') buildRecord(context, 'Name', _idCard.name),
          if (_idCard.country != '')
            buildRecord(context, 'Country', _idCard.country),
          for (CustomField _customField in _idCard.customFields)
            buildRecord(context, _customField.title, _customField.value,
                obscureValue: _customField.obscured,
                isPassword: _customField.fieldType == FieldType.password),
          if (_idCard.additionalInfo != '')
            buildRecord(context, 'Additional info', _idCard.additionalInfo),
        ],
      ),
    );
  }
}
