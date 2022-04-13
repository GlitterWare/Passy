import 'dart:convert';

import 'package:passy/passy_data/json_convertable.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'json_file.dart';

typedef AccountCredentialsFile = JsonFile<AccountCredentials>;

class AccountCredentials implements JsonConvertable {
  String username;
  set password(String value) => _passwordHash = getHash(value).toString();
  String get passwordHash => _passwordHash;

  String _passwordHash;

  AccountCredentials(this.username, String password)
      : _passwordHash = getHash(password).toString();

  AccountCredentials.fromJson(Map<String, dynamic> json)
      : username = json['username'] ?? '',
        _passwordHash = json['passwordHash'] ?? '';

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'passwordHash': _passwordHash,
      };

  static AccountCredentialsFile fromFile(File file,
          {AccountCredentials? value}) =>
      AccountCredentialsFile.fromFile(file,
          constructor: () => value!, fromJson: AccountCredentials.fromJson);
}
