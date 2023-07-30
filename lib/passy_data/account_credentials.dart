import 'dart:io';

import 'hashing_type.dart';
import 'common.dart';
import 'hashing_info.dart';
import 'json_convertable.dart';
import 'json_file.dart';

typedef AccountCredentialsFile = JsonFile<AccountCredentials>;

class AccountCredentials with JsonConvertable {
  String username;
  String passwordHash;
  bool bioAuthEnabled;
  HashingType hashingType;
  HashingInfo? hashingData;

  set password(String value) => passwordHash = getPassyHash(value).toString();

  AccountCredentials(
      {required this.username,
      required this.passwordHash,
      this.bioAuthEnabled = false,
      this.hashingType = HashingType.none,
      this.hashingData});

  AccountCredentials.fromJson(Map<String, dynamic> json)
      : username = json['username'] ?? '',
        passwordHash = json['passwordHash'] ?? '',
        bioAuthEnabled =
            boolFromString(json['bioAuthEnabled'] ?? 'false') ?? false,
        hashingType = hashingTypeFromName(json['hashingType'] ?? 'none') ??
            HashingType.none,
        hashingData = HashingInfo.fromJson(
                hashingTypeFromName(json['hashingType'] ?? 'none') ??
                    HashingType.none)
            ?.call(json['hashingData']);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'passwordHash': passwordHash,
        'bioAuthEnabled': bioAuthEnabled.toString(),
        'hashingType': hashingType.name,
        'hashingData': hashingData?.toJson(),
      };

  static AccountCredentialsFile fromFile(File file,
          {AccountCredentials? value}) =>
      AccountCredentialsFile.fromFile(file,
          constructor: () => value!, fromJson: AccountCredentials.fromJson);
}
