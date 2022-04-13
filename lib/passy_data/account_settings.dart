import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'encrypted_json_file.dart';
import 'json_convertable.dart';
import 'screen.dart';

typedef AccountSettingsFile = EncryptedJsonFile<AccountSettings>;

class AccountSettings implements JsonConvertable {
  String icon;
  Color color;
  Screen defaultScreen;

  AccountSettings.fromJson(Map<String, dynamic> json)
      : icon = json['icon'] ?? 'assets/images/logo_circle.svg',
        color = Color(json['color'] ?? 0xFF9C27B0),
        defaultScreen = screenFromJson[json['defaultScreen']] ?? Screen.main;

  AccountSettings({
    this.icon = 'assets/images/logo_circle.svg',
    this.color = Colors.purple,
    this.defaultScreen = Screen.main,
  });

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'icon': icon,
        'color': color.value,
        'defaultScreen': screenToJson[defaultScreen],
      };

  static AccountSettingsFile fromFile(
    File file, {
    required Encrypter encrypter,
  }) =>
      AccountSettingsFile.fromFile(file,
          encrypter: encrypter,
          constructor: () => AccountSettings(),
          fromJson: AccountSettings.fromJson);
}
