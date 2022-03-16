import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'common.dart';

class AccountInfo {
  String username;
  String icon;
  Color color;
  String get passwordHash => _passwordHash;
  set password(String password) => _passwordHash = getPasswordHash(password);

  String _passwordHash;
  late File _file;

  Future<void> save() async => await _file.writeAsString(jsonEncode(this));

  void saveSync() => _file.writeAsStringSync(jsonEncode(this));

  AccountInfo._(
    this._file,
    this.username,
    this._passwordHash, {
    required this.icon,
    required this.color,
  });

  AccountInfo.create(
    this._file,
    this.username,
    String password, {
    required this.icon,
    required this.color,
  }) : _passwordHash = getPasswordHash(password) {
    _file.createSync(recursive: true);
    _file.writeAsStringSync(jsonEncode(this));
    saveSync();
  }

  factory AccountInfo.fromFile(File file) {
    Map<String, dynamic> _json = jsonDecode(file.readAsStringSync());
    AccountInfo _account = AccountInfo._(
      file,
      _json['username'],
      _json['passwordHash'],
      icon: _json['icon'],
      color: Color(_json['color']),
    );
    return _account;
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'username': username,
        'icon': icon,
        'color': color.value,
        'passwordHash': _passwordHash,
      };

  Map<String, dynamic> toJson() => toMap();
}
