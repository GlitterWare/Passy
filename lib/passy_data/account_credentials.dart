import 'dart:io';

import 'common.dart';
import 'json_convertable.dart';
import 'json_file.dart';

typedef AccountCredentialsFile = JsonFile<AccountCredentials>;

class AccountCredentials with JsonConvertable {
  String username;
  bool bioAuthEnabled;
  String _passwordHash;

  set password(String value) => _passwordHash = getPassyHash(value).toString();
  String get passwordHash => _passwordHash;

  AccountCredentials(
      {required this.username,
      required String password,
      this.bioAuthEnabled = false})
      : _passwordHash = getPassyHash(password).toString();

  AccountCredentials.fromJson(Map<String, dynamic> json)
      : username = json['username'] ?? '',
        _passwordHash = json['passwordHash'] ?? '',
        bioAuthEnabled =
            boolFromString(json['bioAuthEnabled'] ?? 'false') ?? false;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'bioAuthEnabled': bioAuthEnabled.toString(),
        'passwordHash': _passwordHash,
      };

  static AccountCredentialsFile fromFile(File file,
          {AccountCredentials? value}) =>
      AccountCredentialsFile.fromFile(file,
          constructor: () => value!, fromJson: AccountCredentials.fromJson);
}
