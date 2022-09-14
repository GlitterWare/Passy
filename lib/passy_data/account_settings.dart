import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'encrypted_json_file.dart';
import 'json_convertable.dart';
import 'screen.dart';

typedef AccountSettingsFile = EncryptedJsonFile<AccountSettings>;

class AccountSettings with JsonConvertable {
  String icon;
  Color color;
  Screen defaultScreen;
  bool protectScreen;

  AccountSettings.fromJson(Map<String, dynamic> json)
      : icon = json['icon'] ?? 'assets/images/logo_circle.svg',
        color = Color(json['color'] ?? 0xFF9C27B0),
        defaultScreen =
            screenFromJson[json['defaultScreen'] ?? ''] ?? Screen.main,
        protectScreen = json['protectScreen'] ?? true;

  AccountSettings({
    this.icon = 'assets/images/logo_circle.svg',
    this.color = Colors.purple,
    this.defaultScreen = Screen.main,
    this.protectScreen = true,
  });

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'icon': icon,
        'color': color.value,
        'defaultScreen': screenToJson[defaultScreen],
        'protectScreen': protectScreen,
      };

  static AccountSettingsFile fromFile(
    File file, {
    required Encrypter encrypter,
  }) =>
      AccountSettingsFile.fromFile(
        file,
        encrypter: encrypter,
        constructor: () => AccountSettings(),
        fromJson: AccountSettings.fromJson,
      );
}
