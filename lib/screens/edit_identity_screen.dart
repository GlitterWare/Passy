import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/identity.dart' as id;
import 'package:passy/passy_data/loaded_account.dart';

import 'main_screen.dart';
import 'splash_screen.dart';
import 'edit_custom_field_screen.dart';
import 'identities_screen.dart';
import 'identity_screen.dart';

class EditIdentityScreen extends StatefulWidget {
  const EditIdentityScreen({Key? key}) : super(key: key);

  static const routeName = '${IdentityScreen.routeName}/edit';

  @override
  State<StatefulWidget> createState() => _EditIdentityScreen();
}

class _EditIdentityScreen extends State<EditIdentityScreen> {
  bool _isLoaded = false;
  bool _isNew = true;

  String? _key;
  List<CustomField> _customFields = [];
  String _additionalInfo = '';
  List<String> _tags = [];
  String _nickname = '';
  id.Title _title = id.Title.mr;
  String _firstName = '';
  String _middleName = '';
  String _lastName = '';
  id.Gender _gender = id.Gender.male;
  String _email = '';
  String _number = '';
  String _firstAddressLine = '';
  String _secondAddressLine = '';
  String _zipCode = '';
  String _city = '';
  String _country = '';

  @override
  Widget build(BuildContext context) {
    void _onSave() async {
      final LoadedAccount _account = data.loadedAccount!;
      _customFields.removeWhere((element) => element.value == '');
      id.Identity _identityArgs = id.Identity(
        key: _key,
        customFields: _customFields,
        additionalInfo: _additionalInfo,
        tags: _tags,
        nickname: _nickname,
        title: _title,
        firstName: _firstName,
        middleName: _middleName,
        lastName: _lastName,
        gender: _gender,
        email: _email,
        number: _number,
        firstAddressLine: _firstAddressLine,
        secondAddressLine: _secondAddressLine,
        zipCode: _zipCode,
        city: _city,
        country: _country,
      );
      await _account.setIdentity(_identityArgs);
      Navigator.pushNamed(context, SplashScreen.routeName);
      Navigator.popUntil(
          context, (r) => r.settings.name == MainScreen.routeName);
      Navigator.pushNamed(context, IdentitiesScreen.routeName);
      Navigator.pushNamed(context, IdentityScreen.routeName,
          arguments: _identityArgs);
    }

    if (!_isLoaded) {
      Object? _args = ModalRoute.of(context)!.settings.arguments;
      _isNew = _args == null;
      if (!_isNew) {
        id.Identity _identityArgs = _args as id.Identity;
        _key = _identityArgs.key;
        _customFields = _identityArgs.customFields
            .map((e) => CustomField(
                title: e.title,
                fieldType: e.fieldType,
                value: e.value,
                obscured: e.obscured,
                multiline: e.multiline))
            .toList();
        _additionalInfo = _identityArgs.additionalInfo;
        _tags = _identityArgs.tags;
        _nickname = _identityArgs.nickname;
        _title = _identityArgs.title;
        _firstName = _identityArgs.firstName;
        _middleName = _identityArgs.middleName;
        _lastName = _identityArgs.lastName;
        _gender = _identityArgs.gender;
        _email = _identityArgs.email;
        _number = _identityArgs.number;
        _firstAddressLine = _identityArgs.firstAddressLine;
        _secondAddressLine = _identityArgs.secondAddressLine;
        _zipCode = _identityArgs.zipCode;
        _city = _identityArgs.city;
        _country = _identityArgs.country;
      }
      _isLoaded = true;
    }

    return Scaffold(
      appBar: EditScreenAppBar(
        title: localizations.identity.toLowerCase(),
        isNew: _isNew,
        onSave: _onSave,
      ),
      body: ListView(children: [
        PassyPadding(TextFormField(
          initialValue: _nickname,
          decoration: InputDecoration(labelText: localizations.nickname),
          onChanged: (value) => setState(() => _nickname = value.trim()),
        )),
        PassyPadding(EnumDropDownButtonFormField<id.Title>(
          value: _title,
          values: id.Title.values,
          decoration: InputDecoration(labelText: localizations.title),
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            if (value != null) setState(() => _title = value);
          },
        )),
        PassyPadding(TextFormField(
          initialValue: _firstName,
          decoration: InputDecoration(labelText: localizations.firstName),
          onChanged: (value) => setState(() => _firstName = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _middleName,
          decoration: InputDecoration(labelText: localizations.middleName),
          onChanged: (value) => setState(() => _middleName = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _lastName,
          decoration: InputDecoration(labelText: localizations.lastName),
          onChanged: (value) => setState(() => _lastName = value.trim()),
        )),
        PassyPadding(EnumDropDownButtonFormField<id.Gender>(
          value: _gender,
          values: id.Gender.values,
          decoration: InputDecoration(labelText: localizations.gender),
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            if (value != null) setState(() => _gender = value);
          },
        )),
        PassyPadding(TextFormField(
          initialValue: _email,
          decoration: InputDecoration(labelText: localizations.email),
          onChanged: (value) => setState(() => _email = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _number,
          decoration: InputDecoration(labelText: localizations.phoneNumber),
          onChanged: (value) => setState(() => _number = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _firstAddressLine,
          decoration:
              InputDecoration(labelText: localizations.firstAddresssLine),
          onChanged: (value) =>
              setState(() => _firstAddressLine = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _secondAddressLine,
          decoration:
              InputDecoration(labelText: localizations.secondAddressLine),
          onChanged: (value) =>
              setState(() => _secondAddressLine = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _zipCode,
          decoration: InputDecoration(labelText: localizations.zipCode),
          onChanged: (value) => setState(() => _zipCode = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _city,
          decoration: InputDecoration(labelText: localizations.city),
          onChanged: (value) => setState(() => _city = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _country,
          decoration: InputDecoration(labelText: localizations.country),
          onChanged: (value) => setState(() => _country = value.trim()),
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
          keyboardType: TextInputType.multiline,
          maxLines: null,
          initialValue: _additionalInfo,
          decoration: InputDecoration(
            labelText: localizations.additionalInfo,
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
