import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'common.dart';
import 'json_convertable.dart';
import 'json_file.dart';

class PassyInfoFile extends JsonFile<PassyInfo> {
  PassyInfoFile._(File file, {required PassyInfo value})
      : super(file, value: value);

  factory PassyInfoFile(File file) {
    if (file.existsSync()) {
      return PassyInfoFile._(file,
          value: PassyInfo.fromJson(jsonDecode(file.readAsStringSync())));
    }
    file.createSync(recursive: true);
    PassyInfoFile _file = PassyInfoFile._(file, value: PassyInfo());
    _file.saveSync();
    return _file;
  }
}

const _themeModeToJson = {
  ThemeMode.system: 'system',
  ThemeMode.dark: 'dark',
  ThemeMode.light: 'light',
};

const _themeModeFromJson = {
  'system': ThemeMode.system,
  'dark': ThemeMode.dark,
  'light': ThemeMode.light,
};

class PassyInfo implements JsonConvertable {
  String version;
  String lastUsername;
  ThemeMode themeMode;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'lastUsername': lastUsername,
        'themeMode': _themeModeToJson[themeMode],
      };

  factory PassyInfo.fromJson(Map<String, dynamic> json) => PassyInfo(
        version: json['version'] ?? passyVersion,
        lastUsername: json['lastUsername'] ?? '',
        themeMode: _themeModeFromJson[json['themeMode']] ?? ThemeMode.system,
      );

  PassyInfo({
    this.version = passyVersion,
    this.lastUsername = '',
    this.themeMode = ThemeMode.system,
  });
}
