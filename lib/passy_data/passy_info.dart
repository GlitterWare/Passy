import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:universal_io/io.dart';

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.dark: 'dark',
  ThemeMode.light: 'light',
};

class PassyInfo {
  String version;
  String lastUsername;
  ThemeMode themeMode;

  late File _file;

  Future<void> save() => _file.writeAsString(json.encode(this));
  void saveSync() => _file.writeAsStringSync(json.encode(toJson()));

  PassyInfo._(
    this._file, {
    this.version = '0.0.0',
    this.lastUsername = '',
    this.themeMode = ThemeMode.system,
  });

  factory PassyInfo(
    File file, {
    String version = '0.0.0',
    String lastUsername = '',
    ThemeMode themeMode = ThemeMode.system,
    int localPort = 778,
    bool scanNetwork = true,
    String remoteAddress = '127.0.0.1',
    int remotePort = 778,
  }) {
    if (file.existsSync()) {
      Map<String, dynamic> _json = jsonDecode(file.readAsStringSync());
      return PassyInfo._(
        file,
        version: _json['version'] ?? '',
        lastUsername: _json['lastUsername'] ?? '',
        themeMode:
            $enumDecodeNullable(_$ThemeModeEnumMap, _json['themeMode']) ??
                ThemeMode.system,
      );
    }
    file.createSync(recursive: true);
    PassyInfo _data = PassyInfo._(
      file,
      version: version,
      lastUsername: lastUsername,
      themeMode: themeMode,
    );
    _data.saveSync();
    return _data;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'lastUsername': lastUsername,
        'themeMode': _$ThemeModeEnumMap[themeMode],
      };
}
