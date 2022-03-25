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

class PassyData {
  String version;
  SyncMode syncMode;
  String lastUsername;
  ThemeMode themeMode;
  int localPort;
  bool scanNetwork;
  String remoteAddress;
  int remotePort;

  late File _file;

  Future<void> save() async => await _file.writeAsString(json.encode(this));
  void saveSync() => _file.writeAsStringSync(json.encode(toJson()));

  PassyData._(
    this._file, {
    this.version = '0.0.0',
    this.syncMode = kIsWeb ? SyncMode.client : SyncMode.clientAndServer,
    this.lastUsername = '',
    this.themeMode = ThemeMode.system,
    this.localPort = 778,
    this.scanNetwork = true,
    this.remoteAddress = '127.0.0.1',
    this.remotePort = 778,
  });

  factory PassyData(
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
      return PassyData._(
        file,
        syncMode: $enumDecodeNullable(_$SyncModeEnumMap, _json['syncMode']) ??
            SyncMode.clientAndServer,
        version: _json['version'] ?? '',
        lastUsername: _json['lastUsername'] ?? '',
        themeMode:
            $enumDecodeNullable(_$ThemeModeEnumMap, _json['themeMode']) ??
                ThemeMode.system,
        localPort: _json['localPort'],
        scanNetwork: _json['scanNetwork'],
        remoteAddress: _json['remoteAddress'],
        remotePort: _json['remotePort'],
      );
    }
    file.createSync(recursive: true);
    PassyData _data = PassyData._(
      file,
      version: version,
      syncMode: syncMode,
      lastUsername: lastUsername,
      themeMode: themeMode,
      localPort: localPort,
      scanNetwork: scanNetwork,
      remoteAddress: remoteAddress,
      remotePort: remotePort,
    );
    _data.saveSync();
    return _data;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'syncMode': _$SyncModeEnumMap[syncMode],
        'lastUsername': lastUsername,
        'themeMode': _$ThemeModeEnumMap[themeMode],
        'localPort': localPort,
        'scanNetwork': scanNetwork,
        'remoteAddress': remoteAddress,
        'remotePort': remotePort,
      };
}
