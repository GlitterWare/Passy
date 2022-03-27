import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:universal_io/io.dart';

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

class PassyInfo {
  String version;
  SyncMode syncMode;
  String lastUsername;
  ThemeMode themeMode;

  late File _file;

  Future<void> save() => _file.writeAsString(json.encode(this));
  void saveSync() => _file.writeAsStringSync(json.encode(toJson()));

  PassyInfo._(
    this._file, {
    this.version = '0.0.0',
    this.syncMode = kIsWeb ? SyncMode.client : SyncMode.clientAndServer,
    this.lastUsername = '',
    this.themeMode = ThemeMode.system,
  });

  factory PassyInfo(
    File file, {
    String version = '0.0.0',
    SyncMode syncMode = kIsWeb ? SyncMode.client : SyncMode.clientAndServer,
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
        syncMode: $enumDecodeNullable(_$SyncModeEnumMap, _json['syncMode']) ??
            SyncMode.clientAndServer,
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
      syncMode: syncMode,
      lastUsername: lastUsername,
      themeMode: themeMode,
    );
    _data.saveSync();
    return _data;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'syncMode': _$SyncModeEnumMap[syncMode],
        'lastUsername': lastUsername,
        'themeMode': _$ThemeModeEnumMap[themeMode],
      };
}
