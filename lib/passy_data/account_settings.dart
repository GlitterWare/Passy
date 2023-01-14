import 'package:encrypt/encrypt.dart';
import 'dart:io';

import 'encrypted_json_file.dart';
import 'json_convertable.dart';

typedef AccountSettingsFile = EncryptedJsonFile<AccountSettings>;

class AccountSettings with JsonConvertable {
  bool protectScreen;

  AccountSettings.fromJson(Map<String, dynamic> json)
      : protectScreen = json['protectScreen'] ?? true;

  AccountSettings({
    this.protectScreen = true,
  });

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
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
