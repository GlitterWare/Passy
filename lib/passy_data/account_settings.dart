import 'package:encrypt/encrypt.dart';
import 'dart:io';

import 'encrypted_json_file.dart';
import 'json_convertable.dart';

typedef AccountSettingsFile = EncryptedJsonFile<AccountSettings>;

class AccountSettings with JsonConvertable {
  bool protectScreen;
  bool autoScreenLock;

  AccountSettings.fromJson(Map<String, dynamic> json)
      : protectScreen = json['protectScreen'] ?? true,
        autoScreenLock = json['autoScreenLock'] ?? true;

  AccountSettings({
    this.protectScreen = true,
    this.autoScreenLock = true,
  });

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'protectScreen': protectScreen,
        'autoScreenLock': autoScreenLock,
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
