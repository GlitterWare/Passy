import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entry.dart';
import 'encrypted_json_file.dart';

typedef Passwords = PassyEntries<Password>;

class PasswordsJsonFile extends EncryptedJsonFile<Passwords> {
  PasswordsJsonFile._(File file, Encrypter encrypter,
      {required Passwords value})
      : super(file, encrypter, value: value);

  factory PasswordsJsonFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return PasswordsJsonFile._(file, encrypter,
          value: Passwords.fromJson(jsonDecode(
              decrypt(file.readAsStringSync(), encrypter: encrypter))));
    }
    file.createSync(recursive: true);
    PasswordsJsonFile _file =
        PasswordsJsonFile._(file, encrypter, value: Passwords());
    _file.saveSync();
    return _file;
  }
}

class Password extends PassyEntry<Password> {
  static const csvTemplate = {
    'key': 1,
    'nickname': 2,
    'iconName': 3,
    'username': 4,
    'email': 5,
    'password': 6,
    'tfaSecret': 7,
    'website': 8,
    'additionalInfo': 9
  };

  String nickname;
  String iconName;
  String username;
  String email;
  String password;
  String tfaSecret;
  String website;
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;

  Password._({
    required String key,
    this.nickname = '',
    this.iconName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    this.tfaSecret = '',
    this.website = '',
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(key);

  Password({
    this.nickname = '',
    this.iconName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    this.tfaSecret = '',
    this.website = '',
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(DateTime.now().toUtc().toIso8601String());

  Password.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'] ?? '',
        iconName = json['iconName'] ?? '',
        username = json['username'] ?? '',
        email = json['email'] ?? '',
        password = json['password'] ?? '',
        tfaSecret = json['tfaSecret'] ?? '',
        website = json['website'] ?? '',
        customFields = (json['customFields'] as List<dynamic>?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] as String,
        tags = (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  factory Password.fromCSV(
    List<List<dynamic>> csv, {
    Map<String, Map<String, int>> templates = const {},
  }) {
    Map<String, int> _passwordTemplate = templates['password'] ?? csvTemplate;
    Map<String, int> _customFieldTemplate =
        templates['customField'] ?? CustomField.csvTemplate;
    Password? _password;
    List<CustomField> _customFields = [];
    List<String> _tags = [];

    for (List<dynamic> entry in csv) {
      switch (entry[0]) {
        case 'password':
          _password = Password._(
            key: entry[_passwordTemplate['key']!],
            nickname: entry[_passwordTemplate['nickname']!],
            iconName: entry[_passwordTemplate['iconName']!],
            username: entry[_passwordTemplate['username']!],
            email: entry[_passwordTemplate['email']!],
            password: entry[_passwordTemplate['password']!],
            tfaSecret: entry[_passwordTemplate['tfaSecret']!],
            website: entry[_passwordTemplate['website']!],
            additionalInfo: entry[_passwordTemplate['additionalInfo']!],
          );
          break;
        case 'customFields':
          _customFields
              .add(CustomField.fromCSV(entry, template: _customFieldTemplate));
          break;
        case 'tags':
          for (int i = 1; i != entry.length; i++) {
            _tags.add(entry[i]);
          }
          break;
      }
    }

    _password!.customFields = _customFields;
    _password.tags = _tags;
    return _password;
  }

  @override
  int compareTo(Password other) => nickname.compareTo(other.nickname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'nickname': nickname,
        'iconName': iconName,
        'username': username,
        'email': email,
        'password': password,
        'tfaSecret': tfaSecret,
        'website': website,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
      };

  @override
  List<List<dynamic>> toCSV() {
    List<List<dynamic>> _csv = [
      ['password']
    ];
    Map<String, dynamic> _json = toJson();
    List<dynamic> _password = _csv[0];
    for (String key in csvTemplate.keys) {
      _password.add(_json[key]);
    }
    for (CustomField field in customFields) {
      _csv.addAll(field.toCSV());
    }
    if (tags.isNotEmpty) {
      _csv.add(['tags'].followedBy(tags).toList());
    }
    return _csv;
  }
}
