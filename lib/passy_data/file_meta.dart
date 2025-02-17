import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:passy/passy_data/common.dart';
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
    super.synchronized,
    super.tags,
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
          synchronized: json['synchronized'],
          tags: json.containsKey('tags')
              ? (json['tags'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList()
              : [],
          name: json['name'] ?? '',
          virtualPath: json['virtualPath'] ?? '',
        );

  FileMeta.fromCSV(List<dynamic> csv)
      : path = csv[6],
        changed = DateTime.tryParse(csv[7]) ?? DateTime.now().toUtc(),
        modified = DateTime.tryParse(csv[8]) ?? DateTime.now().toUtc(),
        accessed = DateTime.tryParse(csv[9]) ?? DateTime.now().toUtc(),
        size = int.tryParse(csv[10]) ?? 0,
        type = passyFileTypeFromName(csv[11]) ?? PassyFileType.unknown,
        super(
          key: csv[0],
          synchronized: boolFromString(csv[1]),
          tags: (csv[2] as List<dynamic>).map((e) => e.toString()).toList(),
          name: csv[3],
          virtualPath: csv[4],
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'synchronized': synchronized,
      'tags': tags,
      'name': name,
      'virtualPath': virtualPath,
      'fsType': 'f',
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
      synchronized,
      tags,
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

  static Future<FileMeta> fromFile(File file, {String? virtualParent}) async {
    if (virtualParent == '/') virtualParent = null;
    Digest digest = await getFileChecksum(file);
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
          case 'csv':
            type = PassyFileType.text;
            break;
          case 'txt':
            type = PassyFileType.text;
            break;
          case 'md':
            type = PassyFileType.markdown;
            break;
          case 'ico':
            type = PassyFileType.photo;
            break;
          case 'jpeg':
            type = PassyFileType.photo;
            break;
          case 'jpg':
            type = PassyFileType.photo;
            break;
          case 'png':
            type = PassyFileType.photo;
            break;
          case 'svg':
            type = PassyFileType.photo;
            break;
          case 'gif':
            type = PassyFileType.photo;
            break;
          case 'webp':
            type = PassyFileType.photo;
            break;
          case 'mp3':
            type = PassyFileType.audio;
            break;
          case 'wav':
            type = PassyFileType.audio;
            break;
          case 'flac':
            type = PassyFileType.audio;
            break;
          case 'ogg':
            type = PassyFileType.audio;
            break;
          case 'wma':
            type = PassyFileType.audio;
            break;
          case 'aiff':
            type = PassyFileType.audio;
            break;
          case 'm4a':
            type = PassyFileType.audio;
            break;
          case 'opus':
            type = PassyFileType.audio;
            break;
          case 'mp4':
            type = PassyFileType.video;
            break;
          case 'avi':
            type = PassyFileType.video;
            break;
          case 'webm':
            type = PassyFileType.video;
            break;
          case 'mov':
            type = PassyFileType.video;
            break;
          case 'mkv':
            type = PassyFileType.video;
            break;
          case 'wmv':
            type = PassyFileType.video;
            break;
          case 'pdf':
            type = PassyFileType.pdf;
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
