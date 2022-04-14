import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'json_convertable.dart';
import 'json_file.dart';

typedef PassyInfoFile = JsonFile<PassyInfo>;

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

class PassyInfo with JsonConvertable {
  String version;
  String lastUsername;
  ThemeMode themeMode;

  PassyInfo({
    this.version = passyVersion,
    this.lastUsername = '',
    this.themeMode = ThemeMode.dark,
  });

  PassyInfo.fromJson(Map<String, dynamic> json)
      : version = json['version'] ?? passyVersion,
        lastUsername = json['lastUsername'] ?? '',
        themeMode = _themeModeFromJson[json['themeMode']] ?? ThemeMode.dark;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'lastUsername': lastUsername,
        'themeMode': _themeModeToJson[themeMode],
      };

  static PassyInfoFile fromFile(File file) => PassyInfoFile.fromFile(file,
      constructor: () => PassyInfo(), fromJson: PassyInfo.fromJson);
}
