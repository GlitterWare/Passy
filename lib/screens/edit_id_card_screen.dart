import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/loaded_account.dart';

import 'edit_custom_field_screen.dart';
import 'id_cards_screen.dart';
import 'splash_screen.dart';
import 'id_card_screen.dart';
import 'main_screen.dart';

class EditIDCardScreen extends StatefulWidget {
  const EditIDCardScreen({Key? key}) : super(key: key);

  static const routeName = '${IDCardScreen.routeName}/editIDCard';

  @override
  State<StatefulWidget> createState() => _EditIDCardScreen();
}

class _EditIDCardScreen extends State<EditIDCardScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  bool _isLoaded = false;
  bool _isNew = false;

  String? _key;
  List<CustomField> _customFields = [];
  String _additionalInfo = '';
  List<String> _tags = [];
  String _nickname = '';
  List<String> _pictures = [];
  String _type = '';
  String _idNumber = '';
  String _name = '';
  String _issDate = '';
  String _expDate = '';
  String _country = '';

  void _onSave() {
    IDCard _idCardArgs = IDCard(
      key: _key,
      customFields: _customFields,
      additionalInfo: _additionalInfo,
      tags: _tags,
      nickname: _nickname,
      pictures: _pictures,
      type: _type,
      idNumber: _idNumber,
      name: _name,
      issDate: _issDate,
      expDate: _expDate,
      country: _country,
    );
    _account.setIDCard(_idCardArgs);
    Navigator.pushNamed(context, SplashScreen.routeName);
    _account.saveIDCards().whenComplete(() {
      Navigator.popUntil(
          context, (r) => r.settings.name == MainScreen.routeName);
      Navigator.pushNamed(context, IDCardsScreen.routeName);
      Navigator.pushNamed(context, IDCardScreen.routeName,
          arguments: _idCardArgs);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      Object? _args = ModalRoute.of(context)!.settings.arguments;
      _isNew = _args == null;
      if (!_isNew) {
        IDCard _idCardArgs = _args as IDCard;
        _key = _idCardArgs.key;
        _customFields = _idCardArgs.customFields
            .map((e) => CustomField(
                title: e.title,
                fieldType: e.fieldType,
                value: e.value,
                obscured: e.obscured))
            .toList();
        _additionalInfo = _idCardArgs.additionalInfo;
        _tags = _idCardArgs.tags;
        _nickname = _idCardArgs.nickname;
        _pictures = _idCardArgs.pictures;
        _type = _idCardArgs.type;
        _idNumber = _idCardArgs.idNumber;
        _name = _idCardArgs.name;
        _issDate = _idCardArgs.issDate;
        _expDate = _idCardArgs.expDate;
        _country = _idCardArgs.country;
      }
      _isLoaded = true;
    }

    return Scaffold(
      appBar: EditScreenAppBar(
        title: 'ID card',
        onSave: _onSave,
        isNew: _isNew,
      ),
      body: ListView(children: [
        PassyPadding(TextFormField(
          initialValue: _nickname,
          decoration: const InputDecoration(labelText: 'Nickname'),
          onChanged: (value) => setState(() => _nickname = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _type,
          decoration: const InputDecoration(labelText: 'Type'),
          onChanged: (value) => setState(() => _type = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _idNumber,
          decoration: const InputDecoration(labelText: 'ID number'),
          onChanged: (value) => setState(() => _idNumber = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _name,
          decoration: const InputDecoration(labelText: 'Name'),
          onChanged: (value) => setState(() => _name = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _country,
          decoration: const InputDecoration(labelText: 'Country'),
          onChanged: (value) => setState(() => _country = value.trim()),
        )),
        PassyPadding(ThreeWidgetButton(
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.add_rounded),
          ),
          center: const Text('Add custom field'),
          onPressed: () => Navigator.pushNamed(
            context,
            EditCustomFieldScreen.routeName,
          ).then((value) {
            if (value != null) {
              setState(() {
                _customFields.add(value as CustomField);
                PassySort.sortCustomFields(_customFields);
              });
            }
          }),
        )),
        CustomFieldEditorListView(
            customFields: _customFields,
            shouldSort: true,
            padding: PassyTheme.passyPadding),
        PassyPadding(TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            labelText: 'Additional info',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.0),
              borderSide: const BorderSide(color: PassyTheme.lightContentColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.0),
              borderSide:
                  const BorderSide(color: PassyTheme.darkContentSecondaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.0),
              borderSide: const BorderSide(color: PassyTheme.lightContentColor),
            ),
          ),
          onChanged: (value) => setState(() => _additionalInfo = value),
        )),
      ]),
    );
  }
}
