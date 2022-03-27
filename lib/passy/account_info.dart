import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy/loaded_account.dart';
import 'package:universal_io/io.dart';

import 'common.dart';

class AccountInfo {
  String username;
  String icon;
  Color color;
  final String path;

  set password(String value) => _passwordHash = getPasswordHash(value);
  String get passwordHash => _passwordHash;

  String _passwordHash;
  final File _file;

  Future<void> save() => _file.writeAsString(jsonEncode(this));
  void saveSync() => _file.writeAsStringSync(jsonEncode(this));

  LoadedAccount load(Encrypter encrypter) =>
      LoadedAccount(this, encrypter: encrypter);

  AccountInfo._(
    this.path, {
    required this.username,
    required this.icon,
    required this.color,
    required String passwordHash,
    required File file,
  })  : _passwordHash = passwordHash,
        _file = file;

  AccountInfo(
    this.path, {
    required this.username,
    required String password,
    required this.icon,
    required this.color,
  })  : _passwordHash = getPasswordHash(password),
        _file = File(path + Platform.pathSeparator + 'info.json') {
    _file.createSync(recursive: true);
    saveSync();
  }

  factory AccountInfo.fromDirectory(String path) {
    File _file = File(path + Platform.pathSeparator + 'info.json');
    Map<String, dynamic> _json = jsonDecode(_file.readAsStringSync());
    AccountInfo _account = AccountInfo._(
      path,
      username: _json['username'],
      passwordHash: _json['passwordHash'],
      icon: _json['icon'],
      color: Color(_json['color']),
      file: _file,
    );
    return _account;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'passwordHash': _passwordHash,
        'icon': icon,
        'color': color.value,
      };
}
