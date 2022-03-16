import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.dark: 'dark',
  ThemeMode.light: 'light',
};

class PassyData {
  String version;
  String lastUsername;
  ThemeMode theme;

  late File _file;

  Future<void> save() async => await _file.writeAsString(json.encode(this));
  void saveSync() => _file.writeAsStringSync(json.encode(toJson()));

  PassyData(
    this._file, {
    required this.version,
    required this.lastUsername,
    required this.theme,
  }) {
    _file.createSync(recursive: true);
    saveSync();
  }

  factory PassyData.fromFile(File file) {
    Map<String, dynamic> _json = jsonDecode(file.readAsStringSync());
    return PassyData(
      file,
      version: _json['version'] ?? '',
      lastUsername: _json['lastUsername'] ?? '',
      theme: $enumDecodeNullable(_$ThemeModeEnumMap, _json['theme']) ??
          ThemeMode.system,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'version': version,
        'lastUsername': lastUsername,
        'theme': _$ThemeModeEnumMap[theme]
      };

  Map<String, dynamic> toJson() => toMap();
}
