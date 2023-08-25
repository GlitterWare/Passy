import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:io';

import 'encrypted_json_file.dart';
import 'json_convertable.dart';

typedef AccountSettingsFile = EncryptedJsonFile<AccountSettings>;

class AccountSettings with JsonConvertable {
  bool protectScreen;
  bool autoScreenLock;
  RSAKeypair? rsaKeypair;

  AccountSettings.fromJson(Map<String, dynamic> json)
      : protectScreen = json['protectScreen'] ?? true,
        autoScreenLock = json['autoScreenLock'] ?? true,
        rsaKeypair = json['rsaPrivateKey'] is String
            ? RSAKeypair(RSAPrivateKey.fromPEM(json['rsaPrivateKey']))
            : null;

  AccountSettings({
    this.protectScreen = true,
    this.autoScreenLock = true,
    RSAPrivateKey? rsaPrivateKey,
  }) : rsaKeypair =
            rsaPrivateKey is RSAPrivateKey ? RSAKeypair(rsaPrivateKey) : null;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'protectScreen': protectScreen,
        'autoScreenLock': autoScreenLock,
        'rsaPrivateKey': rsaKeypair?.privateKey.toPEM(),
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
