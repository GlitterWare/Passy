import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:otp/otp.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/tfa.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';

import 'edit_custom_field_screen.dart';
import 'password_screen.dart';
import 'splash_screen.dart';
import 'main_screen.dart';
import 'passwords_screen.dart';

class EditPasswordScreen extends StatefulWidget {
  const EditPasswordScreen({Key? key}) : super(key: key);

  static const routeName = '${PasswordScreen.routeName}/edit';

  @override
  State<StatefulWidget> createState() => _EditPasswordScreen();
}

class _EditPasswordScreen extends State<EditPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoaded = false;
  bool _isNew = true;

  String? _key;
  List<CustomField> _customFields = [];
  String _additionalInfo = '';
  List<String> _tags = [];
  String _nickname = '';
  String _username = '';
  String _email = '';
  String _password = '';
  String _tfaSecret = '';
  int _tfaLength = 6;
  int _tfaInterval = 30;
  Algorithm _tfaAlgorithm = Algorithm.SHA1;
  bool _tfaIsGoogle = true;
  bool _tfaIsExpanded = false;
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
        _customFields = _passwordArgs.customFields
            .map((e) => CustomField(
                title: e.title,
                fieldType: e.fieldType,
                value: e.value,
                obscured: e.obscured,
                multiline: e.multiline))
            .toList();
        _additionalInfo = _passwordArgs.additionalInfo;
        _tags = _passwordArgs.tags;
        _nickname = _passwordArgs.nickname;
        _username = _passwordArgs.username;
        _email = _passwordArgs.email;
        _password = _passwordArgs.password;
        _passwordController.text = _password;
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
      appBar: EditScreenAppBar(
        title: localizations.password.toLowerCase(),
        isNew: _isNew,
        onSave: () async {
          final LoadedAccount _account = data.loadedAccount!;
          _customFields.removeWhere((element) => element.value == '');
          Password _passwordArgs = Password(
            key: _key,
            customFields: _customFields,
            additionalInfo: _additionalInfo,
            tags: _tags,
            nickname: _nickname,
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
          Navigator.pushNamed(context, SplashScreen.routeName);
          await _account.setPassword(_passwordArgs);
          if (isAutofill) {
            await AutofillService().resultWithDatasets([
              PwDataset(
                label: _passwordArgs.nickname,
                username: _passwordArgs.username.isNotEmpty
                    ? _passwordArgs.username
                    : _passwordArgs.email,
                password: _passwordArgs.password,
              ),
            ]);
            Navigator.pop(context);
            Navigator.pop(context);
          }
          Navigator.popUntil(
              context, (r) => r.settings.name == MainScreen.routeName);
          Navigator.pushNamed(context, PasswordsScreen.routeName);
          Navigator.pushNamed(context, PasswordScreen.routeName,
              arguments: _passwordArgs);
        },
      ),
      body: ListView(children: [
        PassyPadding(TextFormField(
          initialValue: _nickname,
          decoration: InputDecoration(
            labelText: localizations.nickname,
          ),
          onChanged: (value) => setState(() => _nickname = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _username,
          decoration: InputDecoration(labelText: localizations.username),
          onChanged: (value) => setState(() => _username = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _email,
          decoration: InputDecoration(labelText: localizations.email),
          onChanged: (value) => setState(() => _email = value.trim()),
        )),
        PassyPadding(ButtonedTextFormField(
          controller: _passwordController,
          labelText: localizations.password,
          tooltip: localizations.generate,
          onChanged: (value) => setState(() => _password = value),
          buttonIcon: const Icon(Icons.password_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const StringGeneratorDialog(),
            ).then((value) {
              if (value == null) return;
              _passwordController.text = value;
              setState(() => _password = value);
            });
          },
        )),
        ExpansionPanelList(
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (panelIndex, isExpanded) =>
                setState(() => _tfaIsExpanded = !isExpanded),
            elevation: 0,
            dividerColor: PassyTheme.lightContentSecondaryColor,
            children: [
              ExpansionPanel(
                  backgroundColor: PassyTheme.darkContentColor,
                  isExpanded: _tfaIsExpanded,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(32.0)),
                                color: PassyTheme.darkPassyPurple),
                            child: PassyPadding(Row(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Icon(Icons.security),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text('Two-Factor Authentication')),
                              ],
                            ))));
                  },
                  body: Column(
                    children: [
                      PassyPadding(TextFormField(
                        initialValue: _tfaSecret.replaceFirst('=', ''),
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.secret.toLowerCase()}'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-z]|[A-Z]|[2-7]')),
                          TextInputFormatter.withFunction(
                              (oldValue, newValue) => TextEditingValue(
                                  text: newValue.text.toUpperCase(),
                                  selection: newValue.selection)),
                        ],
                        onChanged: (value) {
                          if (value.length.isOdd) value += '=';
                          setState(() => _tfaSecret = value);
                        },
                      )),
                      PassyPadding(TextFormField(
                        initialValue: _tfaLength.toString(),
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.length.toLowerCase()}'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) =>
                            setState(() => _tfaLength = int.parse(value)),
                      )),
                      PassyPadding(TextFormField(
                        initialValue: _tfaInterval.toString(),
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.interval.toLowerCase()}'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) =>
                            setState(() => _tfaInterval = int.parse(value)),
                      )),
                      PassyPadding(EnumDropDownButtonFormField<Algorithm>(
                        value: _tfaAlgorithm,
                        values: Algorithm.values,
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.algorithm.toLowerCase()}'),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _tfaAlgorithm = value);
                          }
                        },
                      )),
                      PassyPadding(DropdownButtonFormField(
                        items: [
                          DropdownMenuItem(
                            child: Text(
                                '${localizations.true_} (${localizations.recommended.toLowerCase()})'),
                            value: true,
                          ),
                          DropdownMenuItem(
                            child: Text(localizations.false_),
                            value: false,
                          ),
                        ],
                        value: _tfaIsGoogle,
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.isGoogle.replaceRange(0, 1, localizations.isGoogle[0].toLowerCase())}'),
                        onChanged: (value) =>
                            setState(() => _tfaIsGoogle = value as bool),
                      )),
                    ],
                  ))
            ]),
        PassyPadding(TextFormField(
          initialValue: _website,
          decoration: const InputDecoration(labelText: 'Website'),
          onChanged: (value) => setState(() => _website = value),
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
