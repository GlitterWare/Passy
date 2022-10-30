import 'package:passy/passy_data/json_convertable.dart';

class AutoBackupSettings implements JsonConvertable {
  String path;

  /// Backup interval in milliseconds
  int backupInterval;

  /// UTC time of last backup
  DateTime lastBackup;

  AutoBackupSettings({
    required this.path,
    this.backupInterval = 604800000,
    required this.lastBackup,
  });

  @override
  AutoBackupSettings.fromJson(Map<String, dynamic> json)
      : path = json['path'],
        backupInterval = json['backupInterval'],
        lastBackup = DateTime.parse(json['lastBackup']);

  @override
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'backupInterval': backupInterval,
      'lastBackup': lastBackup.toIso8601String(),
    };
  }
}
