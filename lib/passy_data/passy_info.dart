import 'dart:io';

import 'common.dart';
import 'json_convertable.dart';
import 'json_file.dart';

typedef PassyInfoFile = JsonFile<PassyInfo>;

class PassyInfo with JsonConvertable {
  String version;
  String lastUsername;
  String deviceId;

  PassyInfo({
    this.version = passyVersion,
    this.lastUsername = '',
    this.deviceId = '',
  });

  PassyInfo.fromJson(Map<String, dynamic> json)
      : version = json['version'] ?? '0.0.0',
        lastUsername = json['lastUsername'] ?? '',
        deviceId = json['deviceId'] ?? '';

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'lastUsername': lastUsername,
        'deviceId': deviceId,
      };

  static PassyInfoFile fromFile(File file) => PassyInfoFile.fromFile(file,
      constructor: () => PassyInfo(), fromJson: PassyInfo.fromJson);
}
