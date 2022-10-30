import 'dart:io';

import 'common.dart';
import 'json_convertable.dart';
import 'json_file.dart';

typedef AccountCredentialsFile = JsonFile<AccountCredentials>;

class AccountCredentials with JsonConvertable {
  String username;
  String passwordHash;
  bool bioAuthEnabled;

  set password(String value) => passwordHash = getPassyHash(value).toString();

  AccountCredentials(
      {required this.username,
      required this.passwordHash,
      this.bioAuthEnabled = false});

  AccountCredentials.fromJson(Map<String, dynamic> json)
      : username = json['username'] ?? '',
        passwordHash = json['passwordHash'] ?? '',
        bioAuthEnabled =
            boolFromString(json['bioAuthEnabled'] ?? 'false') ?? false;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'passwordHash': passwordHash,
        'bioAuthEnabled': bioAuthEnabled.toString(),
      };

  static AccountCredentialsFile fromFile(File file,
          {AccountCredentials? value}) =>
      AccountCredentialsFile.fromFile(file,
          constructor: () => value!, fromJson: AccountCredentials.fromJson);
}
