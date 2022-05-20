import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/tfa.dart';
import 'package:passy/screens/edit_custom_field_screen.dart';
import 'package:passy/screens/password_screen.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:passy/widgets/elevated_iconed_button.dart';
import 'package:passy/widgets/text_form_field_buttoned.dart';

import 'main_screen.dart';
import 'passwords_screen.dart';

class EditPasswordScreen extends StatefulWidget {
  const EditPasswordScreen({Key? key}) : super(key: key);

  static const routeName = '/editPassword';

  @override
  State<StatefulWidget> createState() => _EditPasswordScreen();
}

class _EditPasswordScreen extends State<EditPasswordScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  bool _isLoaded = false;
  bool _isNew = true;
  String? _key;
  List<CustomField> _customFields = [];
  String _additionalInfo = '';
  List<String> _tags = [];
  String _nickname = '';
  String _iconName = '';
  String _username = '';
  String _email = '';
  String _password = '';
  String _tfaSecret = '';
  int _tfaLength = 6;
  int _tfaInterval = 30;
  Algorithm _tfaAlgorithm = Algorithm.SHA1;
  bool _tfaIsGoogle = true;
  String _website = '';

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      Object? _args = ModalRoute.of(context)!.settings.arguments;
      _isNew = _args == null;
      if (!_isNew) {
        Password _passwordArgs = _args as Password;
        TFA? _tfa = _passwordArgs.tfa;
        _key = _passwordArgs.key;
        _customFields = _passwordArgs.customFields.toList();
        _tags = _passwordArgs.tags;
        _nickname = _passwordArgs.nickname;
        _username = _passwordArgs.username;
        _email = _passwordArgs.email;
        _password = _passwordArgs.password;
        if (_tfa != null) {
          _tfaSecret = _tfa.secret;
          _tfaLength = _tfa.length;
          _tfaInterval = _tfa.interval;
          _tfaAlgorithm = _tfa.algorithm;
          _tfaIsGoogle = _tfa.isGoogle;
        }
        _website = _passwordArgs.website;
      }
      _isLoaded = true;
    }

    return Scaffold(
      appBar: getEditScreenAppBar(
        context,
        title: 'password',
        isNew: _isNew,
        onSave: () {
          for (int i = 0; i != _customFields.length + 1; i++) {
            if (_customFields[i].value == '') _customFields.removeAt(i);
          }
          Password _passwordArgs = Password(
            key: _key,
            customFields: _customFields,
            additionalInfo: _additionalInfo,
            tags: _tags,
            nickname: _nickname,
            iconName: _iconName,
            username: _username,
            email: _email,
            password: _password,
            tfa: _tfaSecret == ''
                ? null
                : TFA(
                    secret: _tfaSecret,
                    length: _tfaLength,
                    interval: _tfaInterval,
                    algorithm: _tfaAlgorithm,
                    isGoogle: _tfaIsGoogle,
                  ),
            website: _website,
          );
          _account.setPassword(_passwordArgs);
          Navigator.pushNamed(context, SplashScreen.routeName);
          _account.save().whenComplete(() {
            Navigator.popUntil(
                context, (r) => r.settings.name == MainScreen.routeName);
            Navigator.pushNamed(context, PasswordsScreen.routeName);
            Navigator.pushNamed(context, PasswordScreen.routeName,
                arguments: _passwordArgs);
          });
        },
      ),
      body: ListView(children: [
        Padding(
          padding: entryPadding,
          child: TextFormField(
            controller: TextEditingController(text: _nickname),
            decoration: const InputDecoration(
              labelText: 'Nickname',
            ),
            onChanged: (value) => _nickname = value,
          ),
        ),
        Padding(
          padding: entryPadding,
          child: TextFormField(
            controller: TextEditingController(text: _username),
            decoration: const InputDecoration(labelText: 'Username'),
            onChanged: (value) => _username = value,
          ),
        ),
        Padding(
          padding: entryPadding,
          child: TextFormField(
            controller: TextEditingController(text: _email),
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (value) => _email = value,
          ),
        ),
        Padding(
          padding: entryPadding,
          child: TextFormField(
            controller: TextEditingController(text: _password),
            decoration: const InputDecoration(labelText: 'Password'),
            onChanged: (value) => _password = value,
          ),
        ),
        Padding(
          padding: entryPadding,
          child: TextFormField(
            controller:
                TextEditingController(text: _tfaSecret.replaceFirst('=', '')),
            decoration: const InputDecoration(labelText: '2FA secret'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'([a-z]|[A-Z]|[2-7])')),
              TextInputFormatter.withFunction((oldValue, newValue) =>
                  TextEditingValue(
                      text: newValue.text.toUpperCase(),
                      selection: newValue.selection)),
            ],
            onChanged: (value) {
              if (value.length.isOdd) value += '=';
              _tfaSecret = value;
            },
          ),
        ),
        Padding(
          padding: entryPadding,
          child: TextFormField(
            controller: TextEditingController(text: _tfaLength.toString()),
            decoration: const InputDecoration(labelText: '2FA length'),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _tfaLength = int.parse(value),
          ),
        ),
        Padding(
          padding: entryPadding,
          child: TextFormField(
            controller: TextEditingController(text: _tfaInterval.toString()),
            decoration: const InputDecoration(labelText: '2FA interval'),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _tfaInterval = int.parse(value),
          ),
        ),
        Padding(
          padding: entryPadding,
          child: DropdownButtonFormField(
            items: [
              DropdownMenuItem(
                child: Text(Algorithm.SHA1.name),
                value: Algorithm.SHA1,
              ),
              DropdownMenuItem(
                child: Text(Algorithm.SHA256.name),
                value: Algorithm.SHA256,
              ),
              DropdownMenuItem(
                child: Text(Algorithm.SHA512.name),
                value: Algorithm.SHA512,
              ),
            ],
            value: _tfaAlgorithm,
            decoration: const InputDecoration(labelText: '2FA algorithm'),
            onChanged: (value) => _tfaAlgorithm = value as Algorithm,
          ),
        ),
        Padding(
          padding: entryPadding,
          child: DropdownButtonFormField(
            items: const [
              DropdownMenuItem(
                child: Text('True (recommended)'),
                value: true,
              ),
              DropdownMenuItem(
                child: Text('False'),
                value: false,
              ),
            ],
            value: _tfaIsGoogle,
            decoration: const InputDecoration(labelText: '2FA is Google'),
            onChanged: (value) => _tfaIsGoogle = value as bool,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) => TextFormFieldButtoned(
            controller: TextEditingController(text: _customFields[index].value),
            labelText: _customFields[index].title,
            buttonIcon: const Icon(Icons.remove_rounded),
            onChanged: (value) => _customFields[index].value = value,
            onPressed: () => setState(() => _customFields.removeAt(index)),
            inputFormatters: [
              if (_customFields[index].fieldType == FieldType.number)
                FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          itemCount: _customFields.length,
        ),
        ElevatedIconedButton(
          leftIcon: const Icon(Icons.add_rounded),
          body: const Text('Add custom field'),
          onPressed: () => Navigator.pushNamed(
            context,
            EditCustomFieldScreen.routeName,
          ).then((value) {
            if (value != null) {
              setState(() => _customFields.add(value as CustomField));
            }
          }),
        ),
        Padding(
          padding: entryPadding,
          child: TextFormField(
            controller: TextEditingController(text: _website),
            decoration: const InputDecoration(labelText: 'Website'),
            onChanged: (value) => _website = value,
          ),
        ),
        Padding(
          padding: entryPadding,
          child: TextFormField(
            controller: TextEditingController(text: _additionalInfo),
            decoration: const InputDecoration(labelText: 'Additional info'),
            onChanged: (value) => _additionalInfo = value,
          ),
        ),
      ]),
    );
  }
}
