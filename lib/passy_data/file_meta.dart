import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:passy/passy_data/passy_fs_meta.dart';
import 'package:passy/passy_data/json_convertable.dart';
import 'package:passy/passy_data/passy_file_type.dart';
import 'package:path/path.dart';

class FileMeta extends PassyFsMeta with JsonConvertable {
  final String path;
  final DateTime changed;
  final DateTime modified;
  final DateTime accessed;
  final int size;
  PassyFileType type;

  FileMeta({
    super.key,
    required super.name,
    required super.virtualPath,
    required this.path,
    required this.changed,
    required this.modified,
    required this.accessed,
    required this.size,
    required this.type,
  });

  FileMeta.fromJson(Map<String, dynamic> json)
      : path = json['path'] ?? '',
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
        super(
          key: json['key'] ??
              DateTime.now().toUtc().toIso8601String().replaceAll(':', 'c'),
          name: json['name'] ?? '',
          virtualPath: json['virtualPath'] ?? '',
        );

  FileMeta.fromCSV(List<dynamic> csv)
      : path = csv[4],
        changed = DateTime.tryParse(csv[5]) ?? DateTime.now().toUtc(),
        modified = DateTime.tryParse(csv[6]) ?? DateTime.now().toUtc(),
        accessed = DateTime.tryParse(csv[7]) ?? DateTime.now().toUtc(),
        size = int.tryParse(csv[8]) ?? 0,
        type = passyFileTypeFromName(csv[9]) ?? PassyFileType.unknown,
        super(
          key: csv[0],
          name: csv[1],
          virtualPath: csv[2],
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'virtualPath': virtualPath,
      'path': path,
      'changed': changed.toIso8601String(),
      'modified': modified.toIso8601String(),
      'accessed': accessed.toIso8601String(),
      'size': size.toString(),
      'type': type.name,
    };
  }

  @override
  List toCSV() {
    return [
      key,
      name,
      virtualPath,
      'f',
      path,
      changed.toIso8601String(),
      modified.toIso8601String(),
      accessed.toIso8601String(),
      size.toString(),
      type.name,
    ];
  }

  factory FileMeta.fromFile(File file, {String? virtualParent}) {
    if (virtualParent == '/') virtualParent = null;
    AccumulatorSink<Digest> output = AccumulatorSink<Digest>();
    ByteConversionSink input = sha256.startChunkedConversion(output);
    RandomAccessFile raf = file.openSync();
    int byte = raf.readByteSync();
    List<int> chunk = [];
    while (byte != -1) {
      chunk.add(byte);
      if (chunk.length == 256) {
        input.add(chunk);
        chunk.clear();
      }
      byte = raf.readByteSync();
    }
    if (chunk.isNotEmpty) {
      input.add(chunk);
    }
    input.close();
    Digest digest = output.events.single;
    String key = digest.toString();
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
          case 'txt':
            type = PassyFileType.text;
            break;
          case 'md':
            type = PassyFileType.markdown;
            break;
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
      key: key,
      virtualPath: '${virtualParent ?? ''}/$name',
      name: name,
      path: file.path,
      changed: stat.changed,
      modified: stat.modified,
      accessed: stat.accessed,
      size: stat.size,
      type: type,
    );
  }
}
