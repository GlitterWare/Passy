import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/json_convertable.dart';
import 'package:passy/passy_data/passy_file_type.dart';
import 'package:path/path.dart';

class FileMeta with JsonConvertable {
  final String name;
  final DateTime changed;
  final DateTime modified;
  final DateTime accessed;
  final PassyFileType type;
  final IV iv;

  FileMeta({
    required this.name,
    required this.changed,
    required this.modified,
    required this.accessed,
    required this.type,
    required this.iv,
  });

  FileMeta.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        changed = json.containsKey('changed')
            ? (DateTime.tryParse(json['changed']) ?? DateTime.now())
            : DateTime.now(),
        modified = json.containsKey('modified')
            ? (DateTime.tryParse(json['modified']) ?? DateTime.now())
            : DateTime.now(),
        accessed = json.containsKey('accessed')
            ? (DateTime.tryParse(json['accessed']) ?? DateTime.now())
            : DateTime.now(),
        type = json.containsKey('type')
            ? passyFileTypeFromName(json['type']) ?? PassyFileType.unknown
            : PassyFileType.unknown,
        iv = json.containsKey('iv')
            ? IV.fromBase64(json['iv'])
            : IV.fromLength(16);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'changed': changed.toIso8601String(),
      'modified': modified.toIso8601String(),
      'accessed': accessed.toIso8601String(),
      'type': type.name,
      'iv': iv.base64,
    };
  }

  factory FileMeta.fromFile(File file, IV? iv) {
    iv ??= IV.fromSecureRandom(16);
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
      type: type,
      iv: iv,
    );
  }
}
