import 'dart:io';

import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/passy_fs_meta.dart';
import 'package:passy/passy_data/json_convertable.dart';
import 'package:passy/passy_data/passy_file_type.dart';
import 'package:path/path.dart';

class FileMeta extends PassyFsMeta with JsonConvertable {
  final String name;
  final String path;
  final String virtualPath;
  final DateTime changed;
  final DateTime modified;
  final DateTime accessed;
  final int size;
  final PassyFileType type;
  EntryStatus status;
  DateTime entryModified;

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
    required this.entryModified,
  }) : super(key: key);

  FileMeta.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        path = json['path'] ?? '',
        virtualPath = json['virtualPath'] ?? '',
        changed = json.containsKey('changed')
            ? (DateTime.tryParse(json['changed']) ?? DateTime.now().toUtc())
            : DateTime.now().toUtc(),
        modified = json.containsKey('modified')
            ? (DateTime.tryParse(json['modified']) ?? DateTime.now().toUtc())
            : DateTime.now().toUtc(),
        accessed = json.containsKey('accessed')
            ? (DateTime.tryParse(json['accessed']) ?? DateTime.now().toUtc())
            : DateTime.now().toUtc(),
        size = json.containsKey('size') ? int.parse(json['size']) : 0,
        type = json.containsKey('type')
            ? passyFileTypeFromName(json['type']) ?? PassyFileType.unknown
            : PassyFileType.unknown,
        status = json.containsKey('status')
            ? entryStatusFromText(json['status']) ?? EntryStatus.removed
            : EntryStatus.removed,
        entryModified = json.containsKey('entryModified')
            ? (DateTime.tryParse(json['entryModified']) ??
                DateTime.now().toUtc())
            : DateTime.now().toUtc(),
        super(
            key: json['key'] ??
                DateTime.now().toUtc().toIso8601String().replaceAll(':', 'c'));

  FileMeta.fromCSV(List<dynamic> csv)
      : name = csv[1],
        path = csv[2],
        virtualPath = csv[3],
        changed = DateTime.tryParse(csv[4]) ?? DateTime.now().toUtc(),
        modified = DateTime.tryParse(csv[5]) ?? DateTime.now().toUtc(),
        accessed = DateTime.tryParse(csv[6]) ?? DateTime.now().toUtc(),
        size = int.tryParse(csv[7]) ?? 0,
        type = passyFileTypeFromName(csv[8]) ?? PassyFileType.unknown,
        status = entryStatusFromText(csv[9]) ?? EntryStatus.removed,
        entryModified = DateTime.tryParse(csv[10]) ?? DateTime.now().toUtc(),
        super(key: csv[0]);

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
      'entryModified': entryModified.toIso8601String(),
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
      entryModified.toIso8601String(),
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
      entryModified: DateTime.now().toUtc(),
    );
  }
}
