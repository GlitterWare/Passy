import 'dart:io';

import 'package:passy/passy_data/passy_file_type.dart';
import 'package:path/path.dart';

class FileMeta {
  final String name;
  final DateTime changed;
  final DateTime modified;
  final DateTime accessed;
  final PassyFileType type;

  FileMeta({
    required this.name,
    required this.changed,
    required this.modified,
    required this.accessed,
    required this.type,
  });

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
      type: type,
    );
  }
}
