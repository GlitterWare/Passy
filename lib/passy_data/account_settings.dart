import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/sync_2d0d0_server_info.dart';
import 'dart:io';

import 'encrypted_json_file.dart';
import 'json_convertable.dart';

typedef AccountSettingsFile = EncryptedJsonFile<AccountSettings>;

class AccountSettings with JsonConvertable {
  bool protectScreen;
  bool autoScreenLock;
  RSAKeypair? rsaKeypair;
  int serverSyncInterval;
  Map<String, Sync2d0d0ServerInfo> serverInfo;
  DateTime? lastSyncDate;

  AccountSettings.fromJson(Map<String, dynamic> json)
      : protectScreen = json['protectScreen'] ?? true,
        autoScreenLock = json['autoScreenLock'] ?? true,
        rsaKeypair = json['rsaPrivateKey'] is String
            ? RSAKeypair(RSAPrivateKey.fromPEM(json['rsaPrivateKey']))
            : null,
        serverSyncInterval = json.containsKey('serverSyncInterval')
            ? (int.tryParse(json['serverSyncInterval']) ?? 15000)
            : 15000,
        serverInfo = json.containsKey('serverInfo')
            ? Map.fromEntries((json['serverInfo'] as List<dynamic>).map((e) {
                Sync2d0d0ServerInfo info = Sync2d0d0ServerInfo.fromJson(e);
                return MapEntry(info.nickname, info);
              }))
            : {},
        lastSyncDate = json['lastSyncDate'] == null
            ? null
            : DateTime.parse(json['lastSyncDate']);

  AccountSettings({
    this.protectScreen = true,
    this.autoScreenLock = true,
    RSAPrivateKey? rsaPrivateKey,
    this.serverSyncInterval = 15000,
    Map<String, Sync2d0d0ServerInfo>? serverInfo,
    this.lastSyncDate,
  })  : rsaKeypair =
            rsaPrivateKey is RSAPrivateKey ? RSAKeypair(rsaPrivateKey) : null,
        serverInfo = serverInfo ?? {};

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'protectScreen': protectScreen,
        'autoScreenLock': autoScreenLock,
        'rsaPrivateKey': rsaKeypair?.privateKey.toPEM(),
        'serverSyncInterval': serverSyncInterval.toString(),
        'serverInfo': serverInfo.values.map((e) => e.toJson()).toList(),
        'lastSyncDate': lastSyncDate?.toIso8601String(),
      };

  static AccountSettingsFile fromFile(
    File file, {
    required Encrypter encrypter,
  }) =>
      AccountSettingsFile.fromFile(
        file,
        encrypter: encrypter,
        constructor: () => AccountSettings(),
        fromJson: AccountSettings.fromJson,
      );
}
