import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'custom_field.dart';
import 'dated_entries.dart';
import 'dated_entry.dart';
import 'encrypted_json_file.dart';

typedef Passwords = DatedEntries<Password>;

class PasswordsFile extends EncryptedJsonFile<Passwords> {
  PasswordsFile._(File file, Encrypter encrypter, {required Passwords value})
      : super(file, encrypter, value: value);

  factory PasswordsFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return PasswordsFile._(file, encrypter,
          value: Passwords.fromJson(jsonDecode(
              decrypt(file.readAsStringSync(), encrypter: encrypter))));
    }
    file.createSync(recursive: true);
    PasswordsFile _file = PasswordsFile._(file, encrypter, value: Passwords());
    _file.saveSync();
    return _file;
  }
}

class Password extends DatedEntry<Password> {
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

  @override
  int compareTo(Password other) => nickname.compareTo(other.nickname);

  factory Password.fromJson(Map<String, dynamic> json) => Password._(
        nickname: json['nickname'] ?? '',
        iconName: json['iconName'] ?? '',
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        tfaSecret: json['tfaSecret'] ?? '',
        website: json['website'] ?? '',
        customFields: (json['customFields'] as List<dynamic>?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo: json['additionalInfo'] as String,
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        creationDate:
            json['creationDate'] ?? DateTime.now().toUtc().toIso8601String(),
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'nickname': nickname,
        'iconName': iconName,
        'username': username,
        'password': password,
        'tfaSecret': tfaSecret,
        'website': website,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
        'creationDate': creationDate,
      };

  Password._({
    required this.nickname,
    required this.iconName,
    required this.username,
    required this.email,
    required this.password,
    required this.tfaSecret,
    required this.website,
    List<CustomField>? customFields,
    required this.additionalInfo,
    List<String>? tags,
    required String creationDate,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(creationDate);

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
}
