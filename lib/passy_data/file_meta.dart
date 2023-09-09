import 'dart:io';

import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/json_convertable.dart';
import 'package:passy/passy_data/passy_file_type.dart';
import 'package:path/path.dart';

class FileMeta with JsonConvertable {
  final String key;
  final String name;
  final DateTime changed;
  final DateTime modified;
  final DateTime accessed;
  final int size;
  final PassyFileType type;
  final EntryStatus status;

  FileMeta({
    String? key,
    required this.name,
    required this.changed,
    required this.modified,
    required this.accessed,
    required this.size,
    required this.type,
    required this.status,
  }) : key = key ?? DateTime.now().toUtc().toIso8601String();

  FileMeta.fromJson(Map<String, dynamic> json)
      : key = json['key'] ?? DateTime.now().toUtc().toIso8601String(),
        name = json['name'] ?? '',
        changed = json.containsKey('changed')
            ? (DateTime.tryParse(json['changed']) ?? DateTime.now())
            : DateTime.now(),
        modified = json.containsKey('modified')
            ? (DateTime.tryParse(json['modified']) ?? DateTime.now())
            : DateTime.now(),
        size = json.containsKey('size') ? int.parse(json['size']) : 0,
        accessed = json.containsKey('accessed')
            ? (DateTime.tryParse(json['accessed']) ?? DateTime.now())
            : DateTime.now(),
        type = json.containsKey('type')
            ? passyFileTypeFromName(json['type']) ?? PassyFileType.unknown
            : PassyFileType.unknown,
        status = json.containsKey('status')
            ? entryStatusFromText(json['status']) ?? EntryStatus.removed
            : EntryStatus.removed;

  @override
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'changed': changed.toIso8601String(),
      'modified': modified.toIso8601String(),
      'accessed': accessed.toIso8601String(),
      'size': size.toString(),
      'type': type.name,
      'status': status.name,
    };
  }

  factory FileMeta.fromFile(File file) {
    FileStat stat = file.statSync();
    String name = basename(file.path);
    PassyFileType type;
    if (name.isEmpty) {
      type = PassyFileType.unknown;
    } else {
      List<String> nameSplit = name.split('.');
      if (nameSplit.length == 1) {
        type = PassyFileType.unknown;
      } else {
        String ext = nameSplit.last;
        switch (ext) {
          case 'ico':
            type = PassyFileType.imageRaster;
            break;
          case 'jpeg':
            type = PassyFileType.imageRaster;
            break;
          case 'jpg':
            type = PassyFileType.imageRaster;
            break;
          case 'png':
            type = PassyFileType.imageRaster;
            break;
          default:
            type = PassyFileType.unknown;
            break;
        }
      }
    }
    return FileMeta(
      name: name,
      changed: stat.changed,
      modified: stat.modified,
      accessed: stat.accessed,
      size: stat.size,
      type: type,
      status: EntryStatus.alive,
    );
  }
}
