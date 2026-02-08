import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:otp/otp.dart';
import 'package:base32/base32.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/custom_field.dart';
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
  final _account = data.loadedAccount!;
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
  Map<String, int>? _emailsCount;
  String _password = '';
  String _lastPassword = '';
  List<String> _oldPasswords = [];
  String _tfaSecret = '';
  int _tfaLength = 6;
  int _tfaInterval = 30;
  Algorithm _tfaAlgorithm = Algorithm.SHA1;
  bool _tfaIsGoogle = true;
  bool _tfaIsExpanded = false;
  TFAType _tfaType = TFAType.TOTP;
  UniqueKey _tfaKey = UniqueKey();
  List<String> _websites = [''];
  final List<TextEditingController> _websitesControllers = [];
  List<String> _attachments = [];
  String _steamSharedSecret = '';
  UniqueKey _tfaSecretFieldKey = UniqueKey();

  @override
  void dispose() {
    super.dispose();
    for (TextEditingController controller in _websitesControllers) {
      controller.dispose();
    }
  }

  void _onSave() async {
    _customFields.removeWhere((element) => element.value == '');
    if (_lastPassword.isNotEmpty) {
      if (_password != _lastPassword) {
        if (_oldPasswords.length > 1) {
          _oldPasswords.removeLast();
        }
        _oldPasswords.insert(0, _lastPassword);
      }
    }
    Password _passwordArgs = Password(
      key: _key,
      customFields: _customFields,
      additionalInfo: _additionalInfo,
      tags: _tags,
      nickname: _nickname,
      username: _username,
      email: _email,
      password: _password,
      oldPasswords: _oldPasswords,
      tfa: _tfaSecret == ''
          ? null
          : TFA(
              secret: _tfaSecret,
              length: _tfaLength,
              interval: _tfaInterval,
              algorithm: _tfaAlgorithm,
              isGoogle: _tfaIsGoogle,
              type: _tfaType,
            ),
      websites: _websites.sublist(0, _websites.length - 1),
      attachments: _attachments,
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
    Navigator.popUntil(context, (r) => r.settings.name == MainScreen.routeName);
    Navigator.pushNamed(context, PasswordsScreen.routeName);
    Navigator.pushNamed(context, PasswordScreen.routeName,
        arguments: _passwordArgs);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      Object? _args = ModalRoute.of(context)!.settings.arguments;
      _isNew = _args == null;
      if (_isNew) {
        _websitesControllers.add(TextEditingController());
      } else {
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
        _lastPassword = _password;
        _oldPasswords = _passwordArgs.oldPasswords;
        _passwordController.text = _password;
        if (_tfa != null) {
          _tfaSecret = _tfa.secret;
          _tfaLength = _tfa.length;
          _tfaInterval = _tfa.interval;
          _tfaAlgorithm = _tfa.algorithm;
          _tfaIsGoogle = _tfa.isGoogle;
          _tfaType = _tfa.type;
        }
        _websites = _passwordArgs.websites.toList();
        if (_websites.length == 1) {
          if (_websites.first.isEmpty) {
            _websites.clear();
          }
        }
        _websites.add('');
        for (int i = 0; i != _websites.length; i++) {
          _websitesControllers.add(TextEditingController.fromValue(
              TextEditingValue(text: _websites[i])));
        }
        _attachments = List.from(_passwordArgs.attachments);
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
        title: localizations.password.toLowerCase(),
        isNew: _isNew,
        onSave: _onSave,
      ),
      body: ListView(children: [
        AttachmentsEditor(
          files: _attachments,
          onFileAdded: (key) => setState(() => _attachments.add(key)),
          onFileRemoved: (key) => setState(() => _attachments.remove(key)),
        ),
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
        PassyPadding(
          Autocomplete<String>(
            initialValue: TextEditingValue(text: _email),
            optionsBuilder: (TextEditingValue textEditingValue) {
              Map<String, int>? emailsCount = _emailsCount;
              if (emailsCount == null) {
                emailsCount = {};
                final emails = _account.passwords.values
                    .map((e) => e.email)
                    .where((e) => e.isNotEmpty)
                    .toList();
                for (String email in emails) {
                  emailsCount[email] = (emailsCount[email] ?? 0) + 1;
                }
                _emailsCount = emailsCount;
              }
              return (emailsCount.entries.toList()
                    ..sort((a, b) => b.value - a.value))
                  .where((e) => e.key.startsWith(textEditingValue.text))
                  .map((e) => e.key);
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController controller,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) =>
                TextFormField(
              decoration: InputDecoration(labelText: localizations.email),
              onChanged: (value) => setState(() => _email = value.trim()),
              autofillHints: const [AutofillHints.email],
              inputFormatters: [FilteringTextInputFormatter.deny(' ')],
              controller: controller,
              focusNode: focusNode,
              onFieldSubmitted: (_) => onFieldSubmitted(),
            ),
            onSelected: (value) => setState(() => _email = value),
          ),
        ),
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
                setState(() => _tfaIsExpanded = isExpanded),
            elevation: 0,
            dividerColor: PassyTheme.of(context).highlightContentSecondaryColor,
            children: [
              ExpansionPanel(
                  backgroundColor: PassyTheme.of(context).contentColor,
                  isExpanded: _tfaIsExpanded,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(32.0)),
                                color: PassyTheme.of(context)
                                    .highlightContentSecondaryColor),
                            child: PassyPadding(Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Icon(Icons.security,
                                      color: PassyTheme.of(context)
                                          .highlightContentTextColor),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text(
                                        style: TextStyle(
                                            color: PassyTheme.of(context)
                                                .highlightContentTextColor),
                                        localizations.twoFactorAuthentication)),
                              ],
                            ))));
                  },
                  body: Column(
                    children: [
                      if (_tfaType == TFAType.Steam)
                        PassyPadding(TextFormField(
                          initialValue: _steamSharedSecret,
                          decoration: const InputDecoration(
                              labelText: 'Steam shared_secret'),
                          onChanged: (value) {
                            String? newTfaSecret;
                            try {
                              newTfaSecret = base32.encode(base64Decode(value));
                              if (newTfaSecret.length.isOdd) {
                                newTfaSecret += '=';
                              }
                            } catch (_) {}
                            setState(() {
                              _steamSharedSecret = value;
                              if (newTfaSecret != null) {
                                _tfaSecret = newTfaSecret;
                                _tfaSecretFieldKey = UniqueKey();
                              }
                            });
                          },
                        )),
                      PassyPadding(TextFormField(
                        key: _tfaSecretFieldKey,
                        enabled: _tfaType != TFAType.Steam,
                        initialValue: _tfaSecret.replaceFirst('=', ''),
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.secret.toLowerCase()}'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-z]|[A-Z]|[0-9]')),
                          TextInputFormatter.withFunction(
                              (oldValue, newValue) => TextEditingValue(
                                  text: newValue.text.toUpperCase(),
                                  selection: newValue.selection)),
                        ],
                        onChanged: (value) {
                          if (!value.contains('0') &&
                              !value.contains('1') &&
                              !value.contains('8') &&
                              !value.contains('9') &&
                              value.length.isOdd) {
                            value += '=';
                          }
                          setState(() => _tfaSecret = value);
                        },
                      )),
                      PassyPadding(EnumDropDownButtonFormField<TFAType>(
                        value: _tfaType,
                        values: TFAType.values,
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.type.toLowerCase()}'),
                        onChanged: (value) {
                          if (value == null) return;
                          if (value == _tfaType) return;
                          setState(() {
                            _tfaType = value;
                            switch (value) {
                              case TFAType.TOTP:
                                _tfaLength = 6;
                                _tfaInterval = 30;
                                break;
                              case TFAType.HOTP:
                                _tfaLength = 6;
                                _tfaInterval = 0;
                                break;
                              case TFAType.Steam:
                                _tfaLength = 5;
                                _tfaInterval = 30;
                                break;
                            }
                            _tfaAlgorithm = Algorithm.SHA1;
                            _tfaIsGoogle = true;
                            _tfaKey = UniqueKey();
                          });
                        },
                      )),
                      PassyPadding(TextFormField(
                        key: _tfaKey,
                        enabled: _tfaType != TFAType.Steam,
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
                        key: _tfaKey,
                        enabled: _tfaType != TFAType.Steam,
                        initialValue: _tfaInterval.toString(),
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${_tfaType == TFAType.HOTP ? localizations.counter.toLowerCase() : localizations.interval.toLowerCase()}'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) =>
                            setState(() => _tfaInterval = int.parse(value)),
                      )),
                      PassyPadding(EnumDropDownButtonFormField<Algorithm>(
                        key: _tfaKey,
                        value: _tfaAlgorithm,
                        values: Algorithm.values,
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.algorithm.toLowerCase()}'),
                        onChanged: _tfaType == TFAType.Steam
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() => _tfaAlgorithm = value);
                                }
                              },
                      )),
                      if (_tfaType != TFAType.Steam)
                        PassyPadding(DropdownButtonFormField(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
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
                          initialValue: _tfaIsGoogle,
                          decoration: InputDecoration(
                              labelText:
                                  '2FA ${localizations.isGoogle.replaceRange(0, 1, localizations.isGoogle[0].toLowerCase())}'),
                          onChanged: (value) =>
                              setState(() => _tfaIsGoogle = value as bool),
                        )),
                    ],
                  ))
            ]),
        for (int i = 0; i != _websites.length; i++)
          PassyPadding(ButtonedTextFormField(
            controller: _websitesControllers[i],
            labelText:
                '${localizations.website}${i == 0 ? '' : ' ' + (i + 1).toString()}',
            onChanged: (value) => setState(() {
              if (value.isNotEmpty) {
                if (i + 1 == _websites.length) {
                  _websites.add('');
                  _websitesControllers.add(TextEditingController());
                }
              } else if (i + 1 != _websites.length) {
                FocusScope.of(context).unfocus();
                setState(() {
                  _websites.removeAt(i);
                  _websitesControllers.removeAt(i);
                });
                return;
              }
              _websites[i] = value;
            }),
            buttonIcon: (_websites.length == 1 || i + 1 == _websites.length)
                ? null
                : const Icon(Icons.remove_rounded),
            tooltip: localizations.remove,
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _websites.removeAt(i);
                _websitesControllers.removeAt(i);
              });
            },
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
          initialValue: _additionalInfo,
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
        const SizedBox(height: floatingActionButtonPadding),
      ]),
    );
  }
}
