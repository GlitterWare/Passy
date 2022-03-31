import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:passy/passy_data/json_convertable.dart';

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.dark: 'dark',
  ThemeMode.light: 'light',
};

class PassyInfo implements JsonConvertable {
  String version;
  String lastUsername;
  ThemeMode themeMode;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'lastUsername': lastUsername,
        'themeMode': _$ThemeModeEnumMap[themeMode],
      };

  factory PassyInfo.fromJson(String json) {
    Map<String, dynamic> _json = jsonDecode(json);
    return PassyInfo(
      version: _json['version'] ?? '',
      lastUsername: _json['lastUsername'] ?? '',
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, _json['themeMode']) ??
          ThemeMode.system,
    );
  }

  PassyInfo({
    this.version = '0.0.0',
    this.lastUsername = '',
    this.themeMode = ThemeMode.system,
  });
}
