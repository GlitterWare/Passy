import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.dark: 'dark',
  ThemeMode.light: 'light',
};

class AppData {
  String version;
  String lastUsername;
  ThemeMode theme;

  late File _file;

  Future<void> save() async => await _file.writeAsString(json.encode(this));
  void saveSync() => _file.writeAsStringSync(json.encode(toJson()));

  AppData(
    this._file, {
    required this.version,
    required this.lastUsername,
    required this.theme,
  }) {
    _file.createSync(recursive: true);
    saveSync();
  }

  factory AppData.fromFile(File file) {
    Map<String, dynamic> _json = jsonDecode(file.readAsStringSync());
    return AppData(
      file,
      version: _json['version'] ?? '',
      lastUsername: _json['lastUsername'] ?? '',
      theme: $enumDecodeNullable(_$ThemeModeEnumMap, _json['theme']) ??
          ThemeMode.system,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'version': version});
    result.addAll({'lastUsername': lastUsername});
    result.addAll({'theme': _$ThemeModeEnumMap[theme]});

    return result;
  }

  Map<String, dynamic> toJson() => toMap();
}
