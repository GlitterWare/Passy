import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

enum SyncMode { clientAndServer, client, server }

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.dark: 'dark',
  ThemeMode.light: 'light',
};

const _$SyncModeEnumMap = {
  SyncMode.clientAndServer: 'clientAndServer',
  SyncMode.client: 'client',
  SyncMode.server: 'server',
};

class PassyData {
  String version;
  SyncMode syncMode;
  String lastUsername;
  ThemeMode theme;

  late File _file;

  Future<void> save() async => await _file.writeAsString(json.encode(this));
  void saveSync() => _file.writeAsStringSync(json.encode(toJson()));

  PassyData(
    this._file, {
    required this.version,
    required this.syncMode,
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
      syncMode: $enumDecodeNullable(_$SyncModeEnumMap, _json['syncMode']) ??
          SyncMode.clientAndServer,
      version: _json['version'] ?? '',
      lastUsername: _json['lastUsername'] ?? '',
      theme: $enumDecodeNullable(_$ThemeModeEnumMap, _json['theme']) ??
          ThemeMode.system,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'version': version,
        'syncMode': _$SyncModeEnumMap[syncMode],
        'lastUsername': lastUsername,
        'theme': _$ThemeModeEnumMap[theme]
      };

  Map<String, dynamic> toJson() => toMap();
}
