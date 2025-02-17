import 'dart:io';

import 'package:passy/passy_data/json_convertable.dart';

import 'auto_backup_settings.dart';
import 'json_file.dart';
import 'passy_app_theme.dart';

typedef LocalSettingsFile = JsonFile<LocalSettings>;

class LocalSettings implements JsonConvertable {
  AutoBackupSettings? autoBackup;
  PassyAppTheme appTheme;

  LocalSettings({this.autoBackup, this.appTheme = PassyAppTheme.classicDark});

  LocalSettings.fromJson(Map<String, dynamic> json)
      : autoBackup = json['autoBackup'] == null
            ? null
            : AutoBackupSettings.fromJson(json['autoBackup']),
        appTheme = json.containsKey('appTheme')
            ? passyAppThemeFromName(json['appTheme']) ??
                PassyAppTheme.classicDark
            : PassyAppTheme.classicDark;

  @override
  Map<String, dynamic> toJson() {
    return {
      'autoBackup': autoBackup,
      'appTheme': appTheme.name,
    };
  }

  static LocalSettingsFile fromFile(File file) =>
      LocalSettingsFile.fromFile(file,
          constructor: () => LocalSettings(), fromJson: LocalSettings.fromJson);
}
