import 'dart:io';

import 'key_derivation_type.dart';
import 'common.dart';
import 'key_derivation_info.dart';
import 'json_convertable.dart';
import 'json_file.dart';

typedef AccountCredentialsFile = JsonFile<AccountCredentials>;

class AccountCredentials with JsonConvertable {
  String username;
  String passwordHash;
  bool bioAuthEnabled;
  KeyDerivationType keyDerivationType;
  KeyDerivationInfo? keyDerivationInfo;

  set password(String value) => passwordHash = getPassyHash(value).toString();

  AccountCredentials(
      {required this.username,
      required this.passwordHash,
      this.bioAuthEnabled = false,
      this.keyDerivationType = KeyDerivationType.none,
      this.keyDerivationInfo});

  AccountCredentials.fromJson(Map<String, dynamic> json)
      : username = json['username'] ?? '',
        passwordHash = json['passwordHash'] ?? '',
        bioAuthEnabled =
            boolFromString(json['bioAuthEnabled'] ?? 'false') ?? false,
        keyDerivationType =
            keyDerivationTypeFromName(json['keyDerivationType'] ?? 'none') ??
                KeyDerivationType.none,
        keyDerivationInfo = KeyDerivationInfo.fromJson(
                keyDerivationTypeFromName(
                        json['keyDerivationType'] ?? 'none') ??
                    KeyDerivationType.none)
            ?.call(json['keyDerivationInfo']);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'passwordHash': passwordHash,
        'bioAuthEnabled': bioAuthEnabled.toString(),
        'keyDerivationType': keyDerivationType.name,
        'keyDerivationInfo': keyDerivationInfo?.toJson(),
      };

  static AccountCredentialsFile fromFile(File file,
          {AccountCredentials? value}) =>
      AccountCredentialsFile.fromFile(file,
          constructor: () => value!, fromJson: AccountCredentials.fromJson);
}
