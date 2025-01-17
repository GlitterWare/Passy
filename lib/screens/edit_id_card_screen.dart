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
  List<String> _attachments = [];

  void _onSave() async {
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
      attachments: _attachments,
    );
    Navigator.pushNamed(context, SplashScreen.routeName);
    await _account.setIDCard(_idCardArgs);
    Navigator.popUntil(context, (r) => r.settings.name == MainScreen.routeName);
    Navigator.pushNamed(context, IDCardsScreen.routeName);
    Navigator.pushNamed(context, IDCardScreen.routeName,
        arguments: _idCardArgs);
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
                obscured: e.obscured,
                multiline: e.multiline))
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
        _attachments = List.from(_idCardArgs.attachments);
      }
      _isLoaded = true;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.done),
        onPressed: _onSave,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: EditScreenAppBar(
        title: localizations.idCard,
        onSave: _onSave,
        isNew: _isNew,
      ),
      body: ListView(children: [
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
          initialValue: _type,
          decoration: InputDecoration(labelText: localizations.type),
          onChanged: (value) => setState(() => _type = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _idNumber,
          decoration: InputDecoration(labelText: localizations.idNumber),
          onChanged: (value) => setState(() => _idNumber = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _name,
          decoration: InputDecoration(labelText: localizations.name),
          onChanged: (value) => setState(() => _name = value.trim()),
        )),
        PassyPadding(MonthPickerFormField(
          key: UniqueKey(),
          initialValue: _issDate,
          title: localizations.dateOfIssue,
          getSelectedDate: () {
            DateTime _now = DateTime.now();
            List<String> _date = _issDate.split('/');
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
            setState(() => _issDate = _month + '/' + _year);
          },
        )),
        PassyPadding(MonthPickerFormField(
          key: UniqueKey(),
          initialValue: _expDate,
          title: localizations.expirationDate,
          getSelectedDate: () {
            DateTime _now = DateTime.now();
            List<String> _date = _expDate.split('/');
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
            setState(() => _expDate = _month + '/' + _year);
          },
        )),
        PassyPadding(TextFormField(
          initialValue: _country,
          decoration: InputDecoration(labelText: localizations.country),
          onChanged: (value) => setState(() => _country = value.trim()),
        )),
        CustomFieldsEditor(
          customFields: _customFields,
          shouldSort: true,
          padding: PassyTheme.of(context).passyPadding,
          constructCustomField: () async => (await Navigator.pushNamed(
            context,
            EditCustomFieldScreen.routeName,
          )) as CustomField?,
        ),
        PassyPadding(TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            labelText: localizations.additionalInfo,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                  color: PassyTheme.of(context).highlightContentColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                  color: PassyTheme.of(context).contentSecondaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                  color: PassyTheme.of(context).highlightContentColor),
            ),
          ),
          onChanged: (value) => setState(() => _additionalInfo = value),
        )),
      ]),
    );
  }
}
