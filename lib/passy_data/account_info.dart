import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:universal_io/io.dart';

import 'package:passy/passy_data/json_convertable.dart';
import 'package:passy/passy_data/json_file.dart';

import 'common.dart';

class AccountInfoFile extends JsonFile<AccountInfo> {
  AccountInfoFile(File file, {required AccountInfo value})
      : super(file, value: value) {
    file.createSync(recursive: true);
    saveSync();
  }
}

class AccountInfo implements JsonConvertable {
  String username;
  String icon;
  Color color;

  set password(String value) => _passwordHash = getHash(value).toString();
  String get passwordHash => _passwordHash;

  String _passwordHash;

  AccountInfo._({
    required this.username,
    required this.icon,
    required this.color,
    required String passwordHash,
  }) : _passwordHash = passwordHash;

  AccountInfo({
    required this.username,
    required String password,
    required this.icon,
    required this.color,
  }) : _passwordHash = getHash(password).toString();

  factory AccountInfo.fromFile(File file) {
    Map<String, dynamic> _json = jsonDecode(file.readAsStringSync());
    AccountInfo _account = AccountInfo._(
      username: _json['username'],
      passwordHash: _json['passwordHash'],
      icon: _json['icon'],
      color: Color(_json['color']),
    );
    return _account;
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'passwordHash': _passwordHash,
        'icon': icon,
        'color': color.value,
      };
}
