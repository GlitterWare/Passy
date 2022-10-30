import 'dart:io';

import 'package:passy/passy_data/json_convertable.dart';

import 'auto_backup_settings.dart';
import 'json_file.dart';

typedef LocalSettingsFile = JsonFile<LocalSettings>;

class LocalSettings implements JsonConvertable {
  AutoBackupSettings? autoBackup;

  LocalSettings({this.autoBackup});

  LocalSettings.fromJson(Map<String, dynamic> json)
      : autoBackup = json['autoBackup'] == null
            ? null
            : AutoBackupSettings.fromJson(json['autoBackup']);

  @override
  Map<String, dynamic> toJson() {
    return {
      'autoBackup': autoBackup,
    };
  }

  static LocalSettingsFile fromFile(File file) =>
      LocalSettingsFile.fromFile(file,
          constructor: () => LocalSettings(), fromJson: LocalSettings.fromJson);
}
