import 'dart:async';

import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';
import 'package:compute/compute.dart';
import 'dart:io';

import 'encrypted_json_file.dart';
import 'json_convertable.dart';

typedef AccountSettingsFile = EncryptedJsonFile<AccountSettings>;

class AccountSettings with JsonConvertable {
  bool protectScreen;
  bool autoScreenLock;
  RSAKeypair? rsaKeypair;
  Completer<RSAKeypair> rsaKeypairCompleter = Completer<RSAKeypair>();

  AccountSettings.fromJson(Map<String, dynamic> json)
      : protectScreen = json['protectScreen'] ?? true,
        autoScreenLock = json['autoScreenLock'] ?? true,
        rsaKeypair = json['rsaPrivateKey'] is String
            ? RSAKeypair(RSAPrivateKey.fromPEM(json['rsaPrivateKey']))
            : null {
    if (rsaKeypair == null) {
      Future(() async {
        RSAKeypair result = await compute(
            (message) => RSAKeypair.fromRandom(keySize: 4096), null);
        rsaKeypair = result;
        rsaKeypairCompleter.complete(result);
      });
    } else {
      rsaKeypairCompleter.complete(rsaKeypair);
    }
  }

  AccountSettings({
    this.protectScreen = true,
    this.autoScreenLock = true,
    RSAPrivateKey? rsaPrivateKey,
  }) : rsaKeypair =
            rsaPrivateKey is RSAPrivateKey ? RSAKeypair(rsaPrivateKey) : null {
    if (rsaKeypair == null) {
      Future(() async {
        RSAKeypair result = await compute(
            (message) => RSAKeypair.fromRandom(keySize: 4096), null);
        rsaKeypair = result;
        rsaKeypairCompleter.complete(result);
      });
    } else {
      rsaKeypairCompleter.complete(rsaKeypair);
    }
  }

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
