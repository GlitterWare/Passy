import 'dart:io';

import 'package:passy/passy_data/csv_convertable.dart';
import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/json_convertable.dart';
import 'package:passy/passy_data/passy_file_type.dart';
import 'package:path/path.dart';

class FileMeta with JsonConvertable, CSVConvertable {
  final String key;
  final String name;
  final String path;
  final String virtualPath;
  final DateTime changed;
  final DateTime modified;
  final DateTime accessed;
  final int size;
  final PassyFileType type;
  final EntryStatus status;

  FileMeta({
    String? key,
    required this.name,
    required this.path,
    required this.virtualPath,
    required this.changed,
    required this.modified,
    required this.accessed,
    required this.size,
    required this.type,
    required this.status,
  }) : key = key ??
            DateTime.now().toUtc().toIso8601String().replaceAll(':', 'c');

  FileMeta.fromJson(Map<String, dynamic> json)
      : key = json['key'] ??
            DateTime.now().toUtc().toIso8601String().replaceAll(':', 'c'),
        name = json['name'] ?? '',
        path = json['path'] ?? '',
        virtualPath = json['virtualPath'] ?? '',
        changed = json.containsKey('changed')
            ? (DateTime.tryParse(json['changed']) ?? DateTime.now())
            : DateTime.now(),
        modified = json.containsKey('modified')
            ? (DateTime.tryParse(json['modified']) ?? DateTime.now())
            : DateTime.now(),
        accessed = json.containsKey('accessed')
            ? (DateTime.tryParse(json['accessed']) ?? DateTime.now())
            : DateTime.now(),
        size = json.containsKey('size') ? int.parse(json['size']) : 0,
        type = json.containsKey('type')
            ? passyFileTypeFromName(json['type']) ?? PassyFileType.unknown
            : PassyFileType.unknown,
        status = json.containsKey('status')
            ? entryStatusFromText(json['status']) ?? EntryStatus.removed
            : EntryStatus.removed;

  FileMeta.fromCSV(List<dynamic> csv)
      : key = csv[0],
        name = csv[1],
        path = csv[2],
        virtualPath = csv[3],
        changed = DateTime.tryParse(csv[4]) ?? DateTime.now(),
        modified = DateTime.tryParse(csv[5]) ?? DateTime.now(),
        accessed = DateTime.tryParse(csv[6]) ?? DateTime.now(),
        size = int.tryParse(csv[7]) ?? 0,
        type = passyFileTypeFromName(csv[8]) ?? PassyFileType.unknown,
        status = entryStatusFromText(csv[9]) ?? EntryStatus.removed;

  @override
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'path': path,
      'virtualPath': virtualPath,
      'changed': changed.toIso8601String(),
      'modified': modified.toIso8601String(),
      'accessed': accessed.toIso8601String(),
      'size': size.toString(),
      'type': type.name,
      'status': status.name,
    };
  }

  @override
  List toCSV() {
    return [
      key,
      name,
      path,
      virtualPath,
      changed.toIso8601String(),
      modified.toIso8601String(),
      accessed.toIso8601String(),
      size.toString(),
      type.name,
      status.name,
    ];
  }

  factory FileMeta.fromFile(File file, {String? virtualParent}) {
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
      virtualPath: '${virtualParent ?? ''}/$name',
      path: file.path,
      changed: stat.changed,
      modified: stat.modified,
      accessed: stat.accessed,
      size: stat.size,
      type: type,
      status: EntryStatus.alive,
    );
  }
}
