import 'dart:convert';

import 'package:passy/passy_data/json_convertable.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'json_file.dart';

class AccountCredentialsFile extends JsonFile<AccountCredentials> {
  AccountCredentialsFile.create(File file, {required AccountCredentials value})
      : super(file, value: value) {
    file.createSync(recursive: true);
    saveSync();
  }

  AccountCredentialsFile.read(File file)
      : super(file, value: AccountCredentials.fromFile(file));
}

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

  factory AccountCredentials.fromFile(File file) =>
      AccountCredentials.fromJson(jsonDecode(file.readAsStringSync()));

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'passwordHash': _passwordHash,
      };
}
