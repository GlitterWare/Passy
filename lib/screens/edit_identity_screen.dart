import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/identity.dart' as id;
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

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
    void _onSave() {
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
      _account.setIdentity(_identityArgs);
      Navigator.pushNamed(context, SplashScreen.routeName);
      _account.save().whenComplete(() {
        Navigator.popUntil(
            context, (r) => r.settings.name == MainScreen.routeName);
        Navigator.pushNamed(context, IdentitiesScreen.routeName);
        Navigator.pushNamed(context, IdentityScreen.routeName,
            arguments: _identityArgs);
      });
    }

    if (!_isLoaded) {
      Object? _args = ModalRoute.of(context)!.settings.arguments;
      _isNew = _args == null;
      if (!_isNew) {
        id.Identity _identityArgs = _args as id.Identity;
        _key = _identityArgs.key;
        _customFields = List<CustomField>.from(_identityArgs.customFields.map(
            (e) => CustomField(
                title: e.title,
                fieldType: e.fieldType,
                value: e.value,
                obscured: e.obscured)));
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
        title: 'identity',
        isNew: _isNew,
        onSave: _onSave,
      ),
      body: ListView(children: [
        PassyPadding(TextFormField(
          initialValue: _nickname,
          decoration: const InputDecoration(labelText: 'Nickname'),
          onChanged: (value) => setState(() => _nickname = value.trim()),
        )),
        PassyPadding(EnumDropDownButtonFormField<id.Title>(
          value: _title,
          values: id.Title.values,
          decoration: const InputDecoration(labelText: 'Title'),
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            if (value != null) setState(() => _title = value);
          },
        )),
        PassyPadding(TextFormField(
          initialValue: _firstName,
          decoration: const InputDecoration(labelText: 'First name'),
          onChanged: (value) => setState(() => _firstName = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _middleName,
          decoration: const InputDecoration(labelText: 'Middle name'),
          onChanged: (value) => setState(() => _middleName = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _lastName,
          decoration: const InputDecoration(labelText: 'Last name'),
          onChanged: (value) => setState(() => _lastName = value.trim()),
        )),
        PassyPadding(EnumDropDownButtonFormField<id.Gender>(
          value: _gender,
          values: id.Gender.values,
          decoration: const InputDecoration(labelText: 'Gender'),
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            if (value != null) setState(() => _gender = value);
          },
        )),
        PassyPadding(TextFormField(
          initialValue: _email,
          decoration: const InputDecoration(labelText: 'Email'),
          onChanged: (value) => setState(() => _email = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _number,
          decoration: const InputDecoration(labelText: 'Number'),
          onChanged: (value) => setState(() => _number = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _firstAddressLine,
          decoration: const InputDecoration(labelText: 'First address line'),
          onChanged: (value) =>
              setState(() => _firstAddressLine = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _secondAddressLine,
          decoration: const InputDecoration(labelText: 'Second address line'),
          onChanged: (value) =>
              setState(() => _secondAddressLine = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _zipCode,
          decoration: const InputDecoration(labelText: 'Zip code'),
          onChanged: (value) => setState(() => _zipCode = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _city,
          decoration: const InputDecoration(labelText: 'City'),
          onChanged: (value) => setState(() => _city = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _country,
          decoration: const InputDecoration(labelText: 'Country'),
          onChanged: (value) => setState(() => _country = value.trim()),
        )),
        PassyPadding(ThreeWidgetButton(
          left: const Icon(Icons.add_rounded),
          center: const Text('Add custom field'),
          onPressed: () => Navigator.pushNamed(
            context,
            EditCustomFieldScreen.routeName,
          ).then((value) {
            if (value != null) {
              setState(() => _customFields.add(value as CustomField));
            }
          }),
        )),
        CustomFieldEditorListView(
            customFields: _customFields, padding: PassyTheme.passyPadding),
        PassyPadding(TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          initialValue: _additionalInfo,
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
