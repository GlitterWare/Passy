import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/encrypted_json_file.dart';

import 'entry_event.dart';
import 'json_convertable.dart';

typedef FileSyncHistoryFile = EncryptedJsonFile<FileSyncHistory>;

class FileSyncHistory with JsonConvertable {
  //int version;
  final Map<String, EntryEvent> files;

  int get length => files.length;

  FileSyncHistory({
    //this.version = 0,
    Map<String, EntryEvent>? files,
  }) : files = files ?? {};

  FileSyncHistory.from(FileSyncHistory other)
      : //version = other.version,
        files = Map<String, EntryEvent>.from(other.files);

  FileSyncHistory.fromJson(Map<String, dynamic> json)
      : //version = int.tryParse(json['version']) ?? 0,
        files = (json['files'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value)));

  @override
  Map<String, dynamic> toJson() => {
        //'version': version.toString(),
        'files': files.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
      };

  static FileSyncHistoryFile fromFile(File file,
          {required Encrypter encrypter}) =>
      FileSyncHistoryFile.fromFile(file,
          encrypter: encrypter,
          constructor: () => FileSyncHistory(),
          fromJson: FileSyncHistory.fromJson);

  void clearRemoved() {
    files.removeWhere((key, value) => value.status == EntryStatus.removed);
  }

  void renew() {
    DateTime _time = DateTime.now().toUtc();
    files.forEach((key, value) => value.lastModified = _time);
  }
}
