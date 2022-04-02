import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'encrypted_json_file.dart';
import 'json_convertable.dart';

class AccountSettingsFile extends EncryptedJsonFile<AccountSettings> {
  AccountSettingsFile._(File file, Encrypter encrypter,
      {required AccountSettings value})
      : super(file, encrypter, value: value);

  factory AccountSettingsFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return AccountSettingsFile._(file, encrypter,
          value: AccountSettings.fromFile(file, encrypter));
    }
    AccountSettingsFile _file =
        AccountSettingsFile._(file, encrypter, value: AccountSettings());
    _file.saveSync();
    return _file;
  }
}

class AccountSettings implements JsonConvertable {
  String icon;
  Color color;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'icon': icon,
        'color': color.value,
      };

  factory AccountSettings.fromJson(Map<String, dynamic> json) =>
      AccountSettings(
        icon: json['icon'],
        color: Color(json['color']),
      );

  factory AccountSettings.fromFile(File file, Encrypter encrypter) =>
      AccountSettings.fromJson(
          jsonDecode(decrypt(file.readAsStringSync(), encrypter: encrypter)));

  AccountSettings({
    this.icon = 'assets/images/logo_circle.svg',
    this.color = Colors.purple,
  });
}
